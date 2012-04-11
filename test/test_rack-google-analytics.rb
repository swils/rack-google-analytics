require File.expand_path('../helper',__FILE__)

class TestRackGoogleAnalytics < Test::Unit::TestCase


  context "Asyncronous" do
    context "default" do
      setup { mock_app :async => true, :account => 'somebody' }
      should "show asyncronous tracker" do
        get "/"
        assert_match %r{\_gaq\.push}, last_response.body
        assert_match %r{\'\_setAccount\', \'somebody\'}, last_response.body
        assert_match %r{</script></head>}, last_response.body
      end

      should "not add tracker to none html content-type" do
        get "/test.xml"
        assert_no_match %r{\_gaq\.push}, last_response.body
        assert_match %r{Xml here}, last_response.body
      end

      should "not add without </head>" do
        get "/bob"
        assert_no_match %r{\_gaq\.push}, last_response.body
        assert_match %r{bob here}, last_response.body
      end
    end


    context "option allow_linker" do
      context "when set to true" do
        setup { mock_app :async => true, :account => 'somebody', :allow_linker => true }
        should "show up as true" do
          get "/"
          assert_match %r{'_setAllowLinker', true}, last_response.body
        end
      end

      context "when set to false" do
        setup { mock_app :async => true, :account => 'somebody', :allow_linker => false }
        should "show up as false" do
          get "/"
          assert_match %r{'_setAllowLinker', false}, last_response.body
        end
      end

      context "when not set" do
        setup { mock_app :async => true, :account => 'somebody' }
        should "not show up" do
          get "/"
          assert_no_match %r{'_setAllowLinker'}, last_response.body
        end

      end
    end


    context "multiple sub domains" do
      setup { mock_app :async => true, :account => 'gonna', :domain_name => 'mydomain.com' }
      should "add multiple domain script" do
        get "/"
        assert_match %r{'_setDomainName', 'mydomain.com'}, last_response.body
      end
    end


    context "multiple top-level domains" do
      setup { mock_app :async => true, :account => 'get', :domain_name => 'none', :allow_linker => true }
      should "add top_level domain script" do
        get "/"
        assert_match %r{'_setDomainName', 'none'}, last_response.body
        assert_match %r{'_setAllowLinker', true}, last_response.body
      end
    end

  end
  
  context "Syncronous" do
    setup { mock_app :async => false, :tracker => 'whatthe' }
    should "show non-asyncronous tracker" do
      get "/bob"
      assert_match %r{_gat._getTracker}, last_response.body
      assert_match %r{</script></body>}, last_response.body
      assert_match %r{"whatthe"}, last_response.body
    end
  end
end
