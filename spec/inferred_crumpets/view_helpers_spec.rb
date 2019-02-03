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

    class User < ActiveRecord::Base; end
    class Person < ActiveRecord::Base; end
    class Organisation < ActiveRecord::Base; end

    stub_const 'ActionController::RoutingError', StandardError

    allow(view_context).to receive(:objects_path) { nil }
    allow(view_context).to receive(:collection_url) { nil }

    allow(view_context).to receive(:controller) { double(:controller, :show => nil) }
    allow(view_context).to receive(:url_for).with(user_class).and_return('/users')
    allow(view_context).to receive(:url_for).with(users).and_return('/users')
    allow(view_context).to receive(:url_for).with(action: :index, controller: 'users').and_return('/users')
    allow(view_context).to receive(:url_for).with(user).and_return('/users/1')
    allow(view_context).to receive(:url_for).with(action: :show, controller: 'users', id: 1).and_return('/users/1')
    allow(view_context).to receive(:url_for).with([user.class]).and_return('/users')
  end


  describe '#build_inferred_crumbs!' do
    subject { view_context.render_inferred_crumbs }

    let(:user_class) { User }
    let(:users) { ActiveRecord::Relation.new }
    let(:user) { User.new }

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

    context 'when can route to action but subject is not linkable' do
      let(:route_checker_class) { double }
      let(:route_checker) { double(view_context: view_context) }
      let(:can_route) { true }
      let(:linkable) { true }
      let(:collection_linkable) { true }

      before do
        stub_const 'InferredCrumpets::RouteChecker', route_checker_class

        allow(route_checker_class).to receive(:new).with(view_context).and_return route_checker
        allow(route_checker).to receive(:linkable?).with(user).and_return linkable
        allow(route_checker).to receive(:linkable?).with([User]).and_return collection_linkable
        allow(route_checker).to receive(:can_route?).and_return can_route

        allow(view_context).to receive(:collection).and_return(users)
        allow(view_context).to receive(:current_object).and_return(user)
        allow(view_context).to receive(:url_for).with([user.class]).and_return('/users')
      end

      context 'on show route' do
        let(:action) { 'show' }

        it 'should infer crumbs: Users / Alice ' do
          expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><span>Alice</span></li></ul>'
        end
      end

      context 'on edit route' do
        let(:action) { 'edit' }

        it 'should infer crumbs: Users / Alice / Edit ' do
          expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><a href="/users/1">Alice</a></li><li class="active"><span>Edit</span></li></ul>'
        end
      end

      context 'on show_details route' do
        let(:action) { 'show_details' }

        it 'should infer crumbs: Users / Alice / Edit ' do
          expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><a href="/users/1">Alice</a></li><li class="active"><span>Edit</span></li></ul>'
        end
      end

      context 'when not linkable' do
        let(:linkable) { false }

        context 'on show route' do
          let(:action) { 'show' }

          it 'should infer crumbs: Users / Alice ' do
            expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><span>Alice</span></li></ul>'
          end
        end

        context 'on edit route' do
          let(:action) { 'edit' }

          it 'should infer crumbs: Users / Alice / Edit ' do
            expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><span>Alice</span></li><li class="active"><span>Edit</span></li></ul>'
          end
        end
      end

      context 'when collection not linkable' do
        let(:collection_linkable) { false }
        let(:linkable) { false }

        context 'on show route' do
          let(:action) { 'show' }

          it 'should infer crumbs: Users / Alice ' do
            expect(subject).to eq '<ul class="breadcrumb"><li><span>Users</span></li><li><span>Alice</span></li></ul>'
          end
        end

        context 'on edit route' do
          let(:action) { 'edit' }

          it 'should infer crumbs: Users / Alice / Edit ' do
            expect(subject).to eq '<ul class="breadcrumb"><li><span>Users</span></li><li><span>Alice</span></li><li class="active"><span>Edit</span></li></ul>'
          end
        end
      end

      context 'when cannot route' do
        let(:can_route) { false }

        context 'on show route' do
          let(:action) { 'show' }

          it 'should infer crumbs: Users / Alice ' do
            expect(subject).to eq '<ul class="breadcrumb"><li><span>Users</span></li><li><span>Alice</span></li></ul>'
          end
        end

        context 'on edit route' do
          let(:action) { 'edit' }

          it 'should infer crumbs: Users / Alice / Edit ' do
            expect(subject).to eq '<ul class="breadcrumb"><li><span>Users</span></li><li><span>Alice</span></li><li class="active"><span>Edit</span></li></ul>'
          end
        end
      end
    end

    context 'when subject is single table inherited' do
      let(:route_checker_class) { double }
      let(:route_checker) { double(view_context: view_context) }
      let(:person_class) { Person }
      let(:person) { Person.new }

      let(:collection_linkable) { true }
      let(:subject_base_linkable) { true }
      let(:subject_base_class_linkable) { true }
      let(:subject_linkable) { true }
      let(:can_route) { true }

      before do
        stub_const 'InferredCrumpets::RouteChecker', route_checker_class

        allow(user).to receive(:becomes).and_return(person)
        allow(user_class).to receive(:base_class).and_return(person_class)

        allow(route_checker_class).to receive(:new).with(view_context).and_return route_checker

        allow(route_checker).to receive(:linkable?).with([User]).and_return collection_linkable
        allow(route_checker).to receive(:linkable?).with([Person]).and_return subject_base_class_linkable
        allow(route_checker).to receive(:linkable?).with(person).and_return subject_base_linkable
        allow(route_checker).to receive(:linkable?).with(user).and_return subject_linkable
        allow(route_checker).to receive(:can_route?).and_return can_route

        allow(view_context).to receive(:collection).and_return(users)
        allow(view_context).to receive(:current_object).and_return(user)
        allow(view_context).to receive(:url_for).with(person_class).and_return('/people')
        allow(view_context).to receive(:url_for).with(person).and_return('/people/1')
        allow(view_context).to receive(:url_for).with([Person]).and_return('/people')
      end

      context 'with no parent' do
        context 'on show route' do
          let(:action) { 'show' }

          it 'should infer crumbs: Users / Alice ' do
            expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><span>Alice</span></li></ul>'
          end
        end

        context 'on edit route' do
          let(:action) { 'edit' }

          it 'should infer crumbs: Users / Alice / Edit' do
            expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><a href="/users/1">Alice</a></li><li class="active"><span>Edit</span></li></ul>'
          end
        end

        context 'when subject is not linkable but base class and collection is' do
          let(:subject_linkable) { false }

          context 'on show route' do
            let(:action) { 'show' }

            it 'should infer crumbs: Users / Alice ' do
              expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><span>Alice</span></li></ul>'
            end
          end

          context 'on edit route' do
            let(:action) { 'edit' }

            it 'should infer crumbs: Users / Alice / Edit' do
              expect(subject).to eq '<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><span>Alice</span></li><li class="active"><span>Edit</span></li></ul>'
            end
          end
        end

        context 'when subject and collection is not linkable but base class and collection is' do
          let(:subject_linkable) { false }
          let(:collection_linkable) { false }

          context 'on show route' do
            let(:action) { 'show' }

            it 'should infer crumbs: Users / Alice ' do
              expect(subject).to eq '<ul class="breadcrumb"><li><a href="/people">Users</a></li><li><span>Alice</span></li></ul>'
            end
          end

          context 'on edit route' do
            let(:action) { 'edit' }

            it 'should infer crumbs: Users / Alice / Edit' do
              expect(subject).to eq '<ul class="breadcrumb"><li><a href="/people">Users</a></li><li><a href="/people/1">Alice</a></li><li class="active"><span>Edit</span></li></ul>'
            end
          end
        end

        context 'when nothing is linkable' do
          let(:subject_linkable) { false }
          let(:collection_linkable) { false }
          let(:subject_base_linkable) { false }
          let(:subject_base_class_linkable) { false }

          context 'on show route' do
            let(:action) { 'show' }

            it 'should infer crumbs: Users / Alice ' do
              expect(subject).to eq '<ul class="breadcrumb"><li><span>Users</span></li><li><span>Alice</span></li></ul>'
            end
          end

          context 'on edit route' do
            let(:action) { 'edit' }

            it 'should infer crumbs: Users / Alice / Edit' do
              expect(subject).to eq '<ul class="breadcrumb"><li><span>Users</span></li><li><span>Alice</span></li><li class="active"><span>Edit</span></li></ul>'
            end
          end
        end

        context 'when cannot route' do
          let(:can_route) { false }

          context 'on show route' do
            let(:action) { 'show' }

            it 'should infer crumbs: Users / Alice ' do
              expect(subject).to eq '<ul class="breadcrumb"><li><span>Users</span></li><li><span>Alice</span></li></ul>'
            end
          end

          context 'on edit route' do
            let(:action) { 'edit' }

            it 'should infer crumbs: Users / Alice / Edit' do
              expect(subject).to eq '<ul class="breadcrumb"><li><span>Users</span></li><li><span>Alice</span></li><li class="active"><span>Edit</span></li></ul>'
            end
          end
        end
      end

      context 'with a parent' do
        let(:parent_class) { Organisation }
        let(:parent) { Organisation.new }
        let(:parent_and_collection_linkable) { true }
        let(:parent_class_linkable) { true }
        let(:subject_class_linkable) { true }

        before do
          allow(parent).to receive(:id).and_return(1)
          allow(parent).to receive(:to_s).and_return('Sealink Travel Group')

          allow(route_checker_class).to receive(:new).with(view_context).and_return route_checker
          allow(route_checker).to receive(:linkable?).with([Organisation, User]).and_return parent_and_collection_linkable
          allow(route_checker).to receive(:linkable?).with(Organisation).and_return parent_class_linkable
          allow(route_checker).to receive(:linkable?).with(Person).and_return subject_class_linkable

          allow(view_context).to receive(:url_for).with(parent_class).and_return('/organisations')
          allow(view_context).to receive(:url_for).with(parent).and_return('/organisations/1')
          allow(view_context).to receive(:url_for).with([parent, Person]).and_return('/organisations/1/people')
          allow(view_context).to receive(:url_for).with([parent, User]).and_return('/organisations/1/users')
          allow(view_context).to receive(:parent_object).and_return(parent)
        end

        context 'when not shallow' do
          let(:subject_linkable) { false }

          context 'on index route' do
            let(:action) { 'show' }

            it 'should infer crumbs: Sealink Travel Group / Users / Alice ' do
              expect(subject).to eq '<ul class="breadcrumb"><li><a href="/organisations/1">Sealink Travel Group</a></li><li><a href="/organisations/1/users">Users</a></li><li><span>Alice</span></li></ul>'
            end
          end

          context 'on edit route' do
            let(:action) { 'edit' }

            it 'should infer crumbs: Sealink Travel Group / Users / Alice / Edit' do
              expect(subject).to eq '<ul class="breadcrumb"><li><a href="/organisations/1">Sealink Travel Group</a></li><li><a href="/organisations/1/users">Users</a></li><li><span>Alice</span></li><li class="active"><span>Edit</span></li></ul>'
            end
          end
        end

        context 'when shallow' do
          context 'on index route' do
            let(:action) { 'show' }

            it 'should infer crumbs: Sealink Travel Group / Users / Alice ' do
              expect(subject).to eq '<ul class="breadcrumb"><li><a href="/organisations/1">Sealink Travel Group</a></li><li><span>Alice</span></li></ul>'
            end
          end

          context 'on edit route' do
            let(:action) { 'edit' }

            it 'should infer crumbs: Sealink Travel Group / Users / Alice / Edit' do
              expect(subject).to eq '<ul class="breadcrumb"><li><a href="/organisations/1">Sealink Travel Group</a></li><li><a href="/users/1">Alice</a></li><li class="active"><span>Edit</span></li></ul>'
            end
          end
        end

        context 'when subject class is not linkable' do
          let(:parent_and_collection_linkable) { false }
          let(:subject_base_linkable) { false }
          let(:subject_base_class_linkable) { false }

          context 'on index route' do
            let(:action) { 'show' }

            it 'should infer crumbs: Sealink Travel Group / Users / Alice ' do
              expect(subject).to eq '<ul class="breadcrumb"><li><a href="/organisations/1">Sealink Travel Group</a></li><li><span>Alice</span></li></ul>'
            end
          end

          context 'on edit route' do
            let(:action) { 'edit' }

            it 'should infer crumbs: Sealink Travel Group / Users / Alice / Edit' do
              expect(subject).to eq '<ul class="breadcrumb"><li><a href="/organisations/1">Sealink Travel Group</a></li><li><a href="/people/1">Alice</a></li><li class="active"><span>Edit</span></li></ul>'
            end
          end
        end

        context 'when not parent_class_linkable' do
          let(:parent_class_linkable) { false }

          context 'on index route' do
            let(:action) { 'show' }

            it 'should infer crumbs: Sealink Travel Group / Users / Alice ' do
              expect(subject).to eq '<ul class="breadcrumb"><li><span>Sealink Travel Group</span></li><li><span>Alice</span></li></ul>'
            end
          end

          context 'on edit route' do
            let(:action) { 'edit' }

            it 'should infer crumbs: Sealink Travel Group / Users / Alice / Edit' do
              expect(subject).to eq '<ul class="breadcrumb"><li><span>Sealink Travel Group</span></li><li><a href="/users/1">Alice</a></li><li class="active"><span>Edit</span></li></ul>'
            end
          end
        end
      end
    end
  end
end
