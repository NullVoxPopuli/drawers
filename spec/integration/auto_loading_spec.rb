# frozen_string_literal: true
require 'rails_helper'

describe 'Auto Loading' do
  context 'in a namespace' do
    context 'with traditionally named files' do
      it 'loads the model' do
        expect(Post).to be_truthy
      end

      it 'loads the serializer' do
        expect(Api::PostSerializer).to be_truthy
      end

      it 'loads the controller' do
        expect(Api::PostsController).to be_truthy
      end

      it 'loads the operation namespaced class' do
        expect(Api::PostOperations::Create.new).to be_truthy
      end

      it 'loads the form' do
        expect(Api::PostForms::NewUser.new).to be_truthy
        expect(Api::PostForms::Update.new).to be_truthy
        expect(Api::PostForms::CreateForm.new).to be_truthy
      end
    end

    context 'with files named after type (and folder named after the resource)' do
      it 'loads the model' do
        expect(Author).to be_truthy
      end

      it 'loads the serializer' do
        expect(Api::AuthorSerializer).to be_truthy
      end

      it 'loads the controller' do
        expect(Api::AuthorsController).to be_truthy
      end

      it 'loads the namespaced opertion class and its parent module' do
        expect(Api::AuthorOperations::Create.new).to be_truthy
      end
    end

    context 'with files that are deeply namespaced' do
      it 'loads the controller' do
        expect(Api::V2::CategoriesController).to be_truthy
      end
    end

    context 'when incorrect / no namespacing is used' do
      it 'cannot find the module and ' do
        expect { CategoryOperations }
          .to raise_error(NameError, /uninitialized constant CategoryOperations/)
      end

      it 'tells the user (dev) what is expected when the namespace is attempted to be used' do
        unable_msg = 'Unable to autoload constant Api::V2::CategoryOperations, expected'
        error_msg = %r{#{unable_msg} .+\/api\/v2\/categories\/operations\.rb to define it}
        expect { Api::V2::CategoryOperations }
          .to raise_error(NameError, error_msg)
      end

      it 'cannot find the class when the module cannot be found' do
        expect { CategoryOperations::Create }
          .to raise_error(NameError, /uninitialized constant CategoryOperations/)
      end
    end
  end

  context 'with files that are not namespaced' do
    it 'loads the serializer' do
      expect(CommentSerializer).to be_truthy
    end

    it 'loads the controller' do
      expect(CommentsController).to be_truthy
    end

    it 'loads the create operation' do
      expect(CommentOperations::Create).to be_truthy
    end

    it 'loads the service' do
      expect(CommentServices::SendToFacebook).to be_truthy
    end
  end

  context 'handles finding top level constants' do
    it 'loads the relationship' do
      expect { Author.create.posts }.to_not raise_error
    end
  end

  context 'with a non-default-ily named file' do
    context 'is configured to find non-default file' do
      before(:each) do
        Drawers.resource_suffixes = ['Thing']
      end

      after(:each) do
        Drawers.resource_suffixes = Drawers::DEFAULT_RESOURCE_SUFFIXES
        Object.send(:remove_const, :CommentThing) if defined? CommentThing
      end

      it 'finds the file' do
        expect { CommentThing }.to_not raise_error
      end
    end

    context 'is not configured to find non-default file' do
      it 'errors' do
        expect { CommentThing }.to raise_error(NameError, /uninitialized constant CommentThing/)
      end
    end
  end
end
