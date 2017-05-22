require "spec_helper"

RSpec.describe InferredCrumpets::ViewHelpers do
  let(:mock_view_class) {
      Class.new do
        include ActionView::Helpers::TagHelper
        include ActionView::Helpers::UrlHelper
        include ActionView::Helpers::CaptureHelper
        attr_accessor :output_buffer
        include Crumpet::ViewHelpers
        include InferredCrumpets::ViewHelpers

        attr_reader :params

        def initialize(params)
          @params = params
        end
      end
    }

    let(:view_context) { MockView.new(:action => action) }
    let(:objects_path) { '/users' }
    let(:parent) { nil }
    let(:new_record) { false }
    let(:id) { new_record ? nil : 1 }

    before do
      Crumpet.configure do |config|
        config.container = :ul
        config.wrapper = :li
        config.default_container_class = 'breadcrumb'
        config.separator = nil
        config.link_last_crumb = false
        config.render_when_blank = false
      end

      stub_const 'MockView', mock_view_class
      stub_const 'ActionController::RoutingError', StandardError

      allow(view_context).to receive(:objects_path) { objects_path }
      allow(view_context).to receive(:collection_url) { objects_path }

      allow(view_context).to receive(:parent) { parent }
      allow(view_context).to receive(:parent_object) { parent }

      allow(view_context).to receive(:controller) { double(:controller, :show => nil) }
      allow(view_context).to receive(:url_for).with(user).and_return('/users/1')
      allow(view_context).to receive(:url_for).with(action: :show, controller: 'users', id: 1).and_return('/users/1')
    end


    describe '#build_inferred_crumbs!' do
      subject { view_context.render_inferred_crumbs }

      let(:user_class) { double(:user_class, table_name: 'users', name: nil) }
      let(:users) { double(:users, class: user_class, to_s: 'User') }
      let(:user) { double(:user, id: id, name: nil, to_s: 'Alice', new_record?: new_record, class: user_class) }

      before do
        view_context.crumbs.clear
        allow(view_context).to receive(:collection).and_return(users)
      end

      context 'for the index' do
        let(:action) { 'index' }

        it 'should infer crumbs: Users' do
          expect(subject).to eq '<ul class="breadcrumb"><li><span>Users</span></li></ul>'
        end
      end

      context 'for a new record' do
        let(:action) { 'new' }
        let(:new_record) { true }

        it 'should infer crumbs: Users / New' do
          expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li class="active"><span>New</span></li></ul>'
        end
      end

      context 'for a record' do
        let(:action) { 'show' }

        before do
          allow(view_context).to receive(:current_object).and_return(user)
        end

        it 'should infer crumbs: Users / Alice' do
          expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><span>Alice</span></li></ul>'
        end

        context 'when editing' do
          let(:action) { 'edit' }

          it 'should infer crumbs: Users / Alice / Edit' do
            expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><a href="/users/1">Alice</a></li><li class="active"><span>Edit</span></li></ul>'
          end
        end
      end
    end
end
