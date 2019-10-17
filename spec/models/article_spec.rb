require 'spec_helper'

# Model taken from the dummy app
describe Article do

  it 'should be translatable' do
    expect(Article).to be_translates
  end

  describe 'localized article' do

    let(:article) { create(:localized_article) }
    subject { article }

    it { expect(article.translations.size).to eq 3 }

    it 'should have italian translation' do
      I18n.with_locale :it do
        expect(article.title).to eq 'Italian title'
        expect(article.body).to  eq 'Italian Body'
      end
    end

    it 'should have hungarian translation' do
      I18n.with_locale :hu do
        expect(article.title).to eq 'Article title'
        expect(article.body).to  eq 'Hungarian Body'
      end
    end

  end

end
