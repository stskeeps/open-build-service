require File.expand_path(File.dirname(__FILE__) + "/..") + "/test_helper"

class IssueControllerTest < ActionController::IntegrationTest
  def test_get_issues
    ActionController::IntegrationTest::reset_auth
    # bugs are public atm. Secret stuff should not get imported.
    get '/issue_trackers'
    assert_response :success
    get '/issue_trackers/bnc'
    assert_response :success
    get '/issue_trackers/bnc/issues/123456'
    assert_response :success

    # as user
    prepare_request_with_user "Iggy", "asdfasdf"
    get '/issue_trackers'
    assert_response :success
    get '/issue_trackers/bnc'
    assert_response :success
#    get '/issue_trackers/bnc/issues'
#    assert_response :success
    get '/issue_trackers/bnc/issues/123456'
    assert_response :success
    assert_tag :tag => 'name', :content => "123456"
    assert_tag :tag => 'issue_tracker', :content => "bnc"
    assert_tag :tag => 'long_name', :content => "bnc#123456"
    assert_tag :tag => 'url', :content => "https://bugzilla.novell.com/show_bug.cgi?id=123456"
    assert_tag :tag => 'state', :content => "CLOSED"
    assert_tag :tag => 'description', :content => "OBS is not bugfree!"
    assert_tag :parent => { :tag => 'owner' }, :tag => 'login', :content => "fred"
    assert_tag :parent => { :tag => 'owner' }, :tag => 'email', :content => "fred@feuerstein.de"
    assert_tag :parent => { :tag => 'owner' }, :tag => 'realname', :content => "Frederic Feuerstone"
    assert_no_tag :tag => 'password'

    # get new, incomplete issue .. don't crash ...
    get '/issue_trackers/bnc/issues/1234'
    assert_response :success
    assert_tag :tag => 'name', :content => "1234"
    assert_tag :tag => 'issue_tracker', :content => "bnc"
    assert_no_tag :tag => 'password'
  end

  def test_get_issue_for_patchinfo_and_project
    ActionController::IntegrationTest::reset_auth
    get '/source/Devel:BaseDistro:Update?view=issues'
    assert_response 401
    get '/source/Devel:BaseDistro:Update/pack3?view=issues'
    assert_response 401

    # as user
    prepare_request_with_user "Iggy", "asdfasdf"
    get '/source/Devel:BaseDistro:Update/pack3?view=issues'
    assert_response :success
    assert_tag :parent => { :tag => 'issue' }, :tag => 'name', :content => "123456"
    assert_tag :parent => { :tag => 'issue' }, :tag => 'issue_tracker', :content => "bnc"
    get '/source/Devel:BaseDistro:Update?view=issues'
    assert_response :success
    assert_tag :parent => { :tag => 'issue' }, :tag => 'name', :content => "123456"
    assert_tag :parent => { :tag => 'issue' }, :tag => 'issue_tracker', :content => "bnc"
  end

  def test_search_issues
    ActionController::IntegrationTest::reset_auth
    get "/search/package_id", :match => 'issue/@name="123456"'
    assert_response 401
    get "/search/package_id", :match => 'issue/@issue_tracker="bnc"'
    assert_response 401
    get "/search/package_id", :match => 'issue/[@name="123456" and @issue_tracker="bnc"]'
    assert_response 401
    get "/search/package_id", :match => 'issue/owner/@login="fred"'
    assert_response 401
    get "/search/package_id", :match => 'issue/@state="RESOLVED"'
    assert_response 401

    # search via bug owner
    prepare_request_with_user "Iggy", "asdfasdf"
    # running patchinfo search as done by webui
    get "/search/package_id", :match => '[issue/[@state="CLOSED" and owner/@login="fred"] and kind="patchinfo"]'
    assert_response :success
    assert_tag :parent => { :tag => "collection" }, :tag => "package", :attributes => { :project => 'Devel:BaseDistro:Update', :name => 'pack3' }

    get "/search/package_id", :match => 'issue/owner/@login="fred"'
    assert_response :success
    assert_tag :parent => { :tag => "collection" }, :tag => "package", :attributes => { :project => 'Devel:BaseDistro:Update', :name => 'pack3' }

    # search for specific issue state, issue is in RESOLVED state actually
    get "/search/package_id", :match => 'issue/@state="OPEN"'
    assert_response :success
    assert_no_tag :parent => { :tag => "collection" }, :tag => "package", :attributes => { :project => 'Devel:BaseDistro:Update', :name => 'pack3' }

    # running patchinfo search as done by webui
    get "/search/package_id", :match => '[kind="patchinfo" and issue/[@state="CLOSED" and owner/@login="fred"]]'
    assert_response :success
    assert_tag :parent => { :tag => "collection" }, :tag => "package", :attributes => { :project => 'Devel:BaseDistro:Update', :name => 'pack3' }

    # test with not matching kind to verify that it does not match
    get "/search/package_id", :match => '[issue/[@state="CLOSED" and owner/@login="fred"] and kind="aggregate"]'
    assert_response :success
    assert_no_tag :parent => { :tag => "collection" }, :tag => "package", :attributes => { :project => 'Devel:BaseDistro:Update', :name => 'pack3' }

    # search via bug issue id
    # FIXME2.3: @issue_name should be named correct, but current XPATH parse can handle that
    get "/search/package_id", :match => 'issue/[@issue_name="123456" and @issue_tracker="bnc"]'
    assert_response :success
    assert_tag :parent => { :tag => "collection" }, :tag => "package", :attributes => { :project => 'Devel:BaseDistro:Update', :name => 'pack3' }
  end

  def test_get_issue_for_linked_packages
    changes = "-------------------------------------------------------------------\n
Blah bnc#13\n
-------------------------------------------------------------------\n
Blah bnc#14\n
-------------------------------------------------------------------\n
Blubber bnc#15\n
"

    prepare_request_with_user "Iggy", "asdfasdf"
    post "/source/BaseDistro/pack1", :cmd => "branch", :target_project => "home:Iggy:branches:BaseDistro"
    assert_response :success
    put "/source/home:Iggy:branches:BaseDistro/pack1/file.changes", changes
    assert_response :success
    post "/source/home:Iggy:branches:BaseDistro/pack1", :cmd => "branch", :target_project => "home:Iggy:branches:BaseDistro", :target_package => "pack_new"
    assert_response :success
    changes += "-------------------------------------------------------------------\n
Aha bnc#123456\n
"
    changes.gsub!(/Blubber/, 'Blabber') # leads to changed
    changes.gsub!(/bnc#14/, '') # leads to removed
    put "/source/home:Iggy:branches:BaseDistro/pack_new/file.changes", changes
    assert_response :success

    get "/source/home:Iggy:branches:BaseDistro/pack1?view=issues"
    assert_response :success
    get "/source/home:Iggy:branches:BaseDistro/pack_new?view=issues"
    assert_response :success
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'kept'}}, :tag => 'name', :content => "13"
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'deleted'}}, :tag => 'name', :content => "14"
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'changed'}}, :tag => 'name', :content => "15"
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'added'}}, :tag => 'name', :content => "123456"

    get "/source/home:Iggy:branches:BaseDistro/pack_new?view=issues&changes=added"
    assert_response :success
    assert_no_tag :parent => { :tag => 'issue', :attributes => {:change => 'kept'}}, :tag => 'name', :content => "13"
    assert_no_tag :parent => { :tag => 'issue', :attributes => {:change => 'deleted'}}, :tag => 'name', :content => "14"
    assert_no_tag :parent => { :tag => 'issue', :attributes => {:change => 'changed'}}, :tag => 'name', :content => "15"
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'added'}}, :tag => 'name', :content => "123456"

    get "/source/home:Iggy:branches:BaseDistro/pack_new?view=issues&changes=kept,deleted"
    assert_response :success
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'kept'}}, :tag => 'name', :content => "13"
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'deleted'}}, :tag => 'name', :content => "14"
    assert_no_tag :parent => { :tag => 'issue', :attributes => {:change => 'changed'}}, :tag => 'name', :content => "15"
    assert_no_tag :parent => { :tag => 'issue', :attributes => {:change => 'added'}}, :tag => 'name', :content => "123456"

    get "/source/home:Iggy:branches:BaseDistro?view=issues&changes=kept,deleted"
    assert_response :success
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'kept'}}, :tag => 'name', :content => "13"
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'deleted'}}, :tag => 'name', :content => "14"
    assert_no_tag :parent => { :tag => 'issue', :attributes => {:change => 'changed'}}, :tag => 'name', :content => "15"
    assert_no_tag :parent => { :tag => 'issue', :attributes => {:change => 'added'}}, :tag => 'name', :content => "123456"

    get "/source/home:Iggy:branches:BaseDistro?view=issues&login=unknown"
    assert_response :success
    assert_no_tag :parent => { :tag => 'issue' }
    get "/source/home:Iggy:branches:BaseDistro/pack_new?view=issues&login=unknown"
    assert_response :success
    assert_no_tag :parent => { :tag => 'issue' }

    get "/source/home:Iggy:branches:BaseDistro?view=issues&login=fred"
    assert_response :success
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'added'}}, :tag => 'name', :content => "123456"
    get "/source/home:Iggy:branches:BaseDistro/pack_new?view=issues&login=fred"
    assert_response :success
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'added'}}, :tag => 'name', :content => "123456"

    get "/source/home:Iggy:branches:BaseDistro?view=issues&states=FANTASY"
    assert_response :success
    assert_no_tag :parent => { :tag => 'issue' }
    get "/source/home:Iggy:branches:BaseDistro/pack_new?view=issues&states=FANTASY"
    assert_response :success
    assert_no_tag :parent => { :tag => 'issue' }

    get "/source/home:Iggy:branches:BaseDistro?view=issues&states=OPEN,CLOSED"
    assert_response :success
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'added'}}, :tag => 'name', :content => "123456"
    get "/source/home:Iggy:branches:BaseDistro/pack_new?view=issues&states=OPEN,CLOSED"
    assert_response :success
    assert_tag :parent => { :tag => 'issue', :attributes => {:change => 'added'}}, :tag => 'name', :content => "123456"

    #cleanup
    delete "/source/home:Iggy:branches:BaseDistro"
    assert_response :success
  end

end
