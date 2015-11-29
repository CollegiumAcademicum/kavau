require 'rails_helper'

RSpec.describe LettersController, type: :controller do
  before(:each){ sign_in create(:accountant) }

  describe "get index" do
    it "assigns all letters as @letters" do
      letter = create :letter
      get :index, type: 'Letter'
      expect(assigns(:letters)).to eq([letter])
    end

    it "renders index" do
      get :index, type: 'Letter'
      expect(response).to render_template(:index)
    end
  end

  ['StandardLetter', 'BalanceLetter', 'TerminationLetter'].each do |letter_type|
    context "#{letter_type}" do
      describe "get show" do
        before(:each){ @letter = create letter_type.underscore }

        it "assigns the requested letter" do
          get :show, type: letter_type, id: @letter
          expect(assigns(:letter)).to eq(@letter)
        end

        it "renders show" do
          get :show, type: letter_type, id: @letter
          expect(response).to render_template(:show)
        end
      end

      describe "get new" do
        it "assigns a new #{letter_type} as letter" do
          get :new, type: letter_type
          expect(assigns(:letter)).to be_a_new(letter_type.constantize)
          expect(assigns(:type)).to eq(letter_type)
        end

        it "renders the new template" do
          get :new, type: letter_type
          expect(response).to render_template(:new)
        end
      end

      describe "post create" do
        it "assign the #{letter_type} as letter" do
          post :create, type: letter_type, letter_type.underscore => attributes_for(letter_type.underscore)
          expect(assigns(:letter)).to be_a(letter_type.constantize)
          expect(assigns(:letter)).to be_persisted
        end

        it "is successfull" do
          post :create, type: letter_type, letter_type.underscore => attributes_for(letter_type.underscore)
          expect(response.status).to eq 302
        end

        it "redirects to the letter" do
          post :create, type: letter_type, letter_type.underscore => attributes_for(letter_type.underscore)
          expect(response).to redirect_to("/#{letter_type.underscore.pluralize}/#{Letter.last.id}")
        end

        it "renders the new template if it fails" do
          do_not(:save, letter_type.constantize)
          expect{
            post :create, type: letter_type, letter_type.underscore => attributes_for(letter_type.underscore)
          }.not_to change{letter_type.constantize.count}
          expect(response).to render_template(:new)  
        end
      end

      describe "get edit" do
        before(:each){ @letter = create letter_type.underscore }

        it "assigns the requested letter" do
          get :edit, type: letter_type, id: @letter
          expect(assigns(:letter)).to eq(@letter)
        end

        it "renders edit" do
          get :edit, type: letter_type, id: @letter
          expect(response).to render_template(:edit)
        end
      end

      describe "Put update" do
        before(:each){ @letter = create letter_type.underscore }

        it "assigns the requested letter" do
          put :update, type: letter_type, id: @letter, letter_type.underscore => {content: 'New text'}
          expect(assigns(:letter)).to eq(@letter)
        end

        it "is successfull" do
          put :update, type: letter_type, id: @letter, letter_type.underscore => {content: 'New text'}
          expect(response.status).to eq 302
        end

        it "redirects to the letter" do
          put :update, type: letter_type, id: @letter, letter_type.underscore => {content: 'New text'}
          expect(response).to redirect_to("/#{letter_type.underscore.pluralize}/#{@letter.id}")
        end

        it "rerenders edit if update fails" do
          do_not(:save, letter_type.constantize)
          put :update, type: letter_type, id: @letter, letter_type.underscore => {content: 'New text'}
          expect(response).to render_template(:edit)
        end
      end

      describe "delete destroy" do
        before(:each){ @letter = create letter_type.underscore }

        it "assigns the requested letter" do 
          delete :destroy, type: letter_type, id: @letter.id
          expect(assigns(:letter)).to eq(@letter)
        end

        it "is successfull" do
          expect{ 
            delete :destroy, type: letter_type, id: @letter.id
          }.to change{ letter_type.constantize.count }
        end
      end
    end
  end
end
