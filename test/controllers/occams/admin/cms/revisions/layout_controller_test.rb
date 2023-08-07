# frozen_string_literal: true

require_relative "../../../../../test_helper"

class Occams::Admin::Cms::Revisions::LayoutControllerTest < ActionDispatch::IntegrationTest
  setup do
    @site     = occams_cms_sites(:default)
    @layout   = occams_cms_layouts(:default)
    @revision = occams_cms_revisions(:layout)
  end

  def test_get_index
    r :get, occams_admin_cms_site_layout_revisions_path(@site, @layout)
    assert_response :redirect
    assert_redirected_to action: :show, id: @revision
  end

  def test_get_index_with_no_revisions
    Occams::Cms::Revision.delete_all
    r :get, occams_admin_cms_site_layout_revisions_path(@site, @layout)
    assert_response :redirect
    assert_redirected_to edit_occams_admin_cms_site_layout_path(@site, @layout)
  end

  def test_get_show
    r :get, occams_admin_cms_site_layout_revision_path(@site, @layout, @revision)
    assert_response :success
    assert assigns(:record)
    assert assigns(:revision)
    assert assigns(:record).is_a?(Occams::Cms::Layout)
    assert_template :show
  end

  def test_get_show_for_invalid_record
    r :get, occams_admin_cms_site_layout_revision_path(@site, "invalid", @revision)
    assert_response :redirect
    assert_redirected_to occams_admin_cms_site_layouts_path(@site)
    assert_equal "Record Not Found", flash[:danger]
  end

  def test_get_show_failure
    r :get, occams_admin_cms_site_layout_revision_path(@site, @layout, "invalid")
    assert_response :redirect
    assert assigns(:record)
    assert_redirected_to edit_occams_admin_cms_site_layout_path(@site, assigns(:record))
    assert_equal "Revision Not Found", flash[:danger]
  end

  def test_revert
    assert_difference -> { @layout.revisions.count } do
      r :patch, revert_occams_admin_cms_site_layout_revision_path(@site, @layout, @revision)
      assert_response :redirect
      assert_redirected_to edit_occams_admin_cms_site_layout_path(@site, @layout)
      assert_equal "Content Reverted", flash[:success]

      @layout.reload
      assert_equal "revision {{cms:fragment content}}", @layout.content
      assert_equal "revision css", @layout.css
      assert_equal "revision js", @layout.js
    end
  end
end
