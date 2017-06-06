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
    # let(:objects_path) { '/users' }
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

      module ActiveRecord
        class Base; end
        class Relation; end
      end

      stub_const 'ActionController::RoutingError', StandardError

      allow(view_context).to receive(:objects_path) { nil }
      allow(view_context).to receive(:collection_url) { nil }

      allow(view_context).to receive(:controller) { double(:controller, :show => nil) }
      allow(view_context).to receive(:url_for).with(user_class).and_return('/users')
      allow(view_context).to receive(:url_for).with(users).and_return('/users')
      allow(view_context).to receive(:url_for).with(action: :index, controller: 'users').and_return('/users')
      allow(view_context).to receive(:url_for).with(user).and_return('/users/1')
      allow(view_context).to receive(:url_for).with(action: :show, controller: 'users', id: 1).and_return('/users/1')
    end


    describe '#build_inferred_crumbs!' do
      subject { view_context.render_inferred_crumbs }

      let(:user_class) { ActiveRecord::Base }
      let(:users) { ActiveRecord::Relation.new }
      let(:user) { ActiveRecord::Base.new }

      before do
        allow(user_class).to receive(:table_name).and_return('users')
        allow(user_class).to receive(:name).and_return(nil)

        allow(users).to receive(:class).and_return(user_class)
        allow(users).to receive(:to_s).and_return('User')

        allow(user).to receive(:id).and_return(id)
        allow(user).to receive(:name).and_return(nil)
        allow(user).to receive(:to_s).and_return('Alice')
        allow(user).to receive(:new_record?).and_return(new_record)
        allow(user).to receive(:class).and_return(user_class)
      end

      context 'for the index' do
        let(:action) { 'index' }

        before do
          allow(view_context).to receive(:collection).and_return(users)
        end

        it 'should infer crumbs: Users' do
          expect(subject).to eq '<ul class="breadcrumb"><li><span>Users</span></li></ul>'
        end
      end

      context 'for a new record' do
        let(:action) { 'new' }
        let(:new_record) { true }

        before do
          allow(view_context).to receive(:collection).and_return(users)
          allow(view_context).to receive(:current_object).and_return(user)
          allow(view_context).to receive(:parent) { parent }
          allow(view_context).to receive(:parent_object) { parent }
        end

        it 'should infer crumbs: Users / New' do
          expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li class="active"><span>New</span></li></ul>'
        end
      end

      context 'for a record' do
        let(:action) { 'show' }

        before do
          allow(view_context).to receive(:collection).and_return(users)
          allow(view_context).to receive(:current_object).and_return(user)
          # allow(view_context).to receive(:parent) { parent }
          # allow(view_context).to receive(:parent_object) { parent }
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
