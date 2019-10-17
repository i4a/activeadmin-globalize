require 'spec_helper'

feature 'Article localization features', :js do

  given!(:current_user) { create(:user) }

  before do
    login_user(current_user)
  end

  scenario 'Create an article', :js do

    my_title = 'A new article title'
    my_body = 'Something interesting to say'

    within(main_menubar) { click_link 'Articles' }
    within(action_bar) { click_link 'New Article' }

    within page_body do
      # This will fill visible fields i.e. for the default locale
      fill_in 'Title', with: my_title
      fill_in 'Body', with: my_body
      submit_button.click
    end

    page.should have_content 'Article was successfully created.'

    # Retrieve created article from database
    page.should have_content my_title
    page.should have_content my_body
  end

  context 'Viewing article translations' do

    given!(:article) { create(:localized_article) }

    before do
      # Load article page
      ensure_on(admin_article_path(article))
    end

    # See spec/dummy/app/admin/articles.rb
    scenario 'Viewing a translated article' do

      # First row shows default locale with label title
      within first_table_row do
        page.should have_css 'th', text: 'TITLE'
        page.should have_css 'span.field-translation', text: article.title
      end
      # Second row shows italian title by default
      within second_table_row do
        page.should have_css 'th', text: 'ITALIAN TITLE'
        page.should have_css 'span.field-translation', text: article.translation_for(:it).title
      end

    end

    scenario 'Switch inline translations' do

      # First row shows default locale with label title
      within first_table_row do
        page.should have_css 'th', text: 'TITLE'
        page.should have_css 'span.field-translation', text: article.title

        flag_link(:hu).find(:xpath, '..').should have_css '.empty:not(.active)'
        flag_link(:it).find(:xpath, '..').should have_css ':not(.empty):not(.active)'

        flag_link(:hu).click # change shown translation
        flag_link(:hu).find(:xpath, '..').should have_css '.empty.active'

        flag_link(:it).click # change shown translation
        flag_link(:it).find(:xpath, '..').should have_css ':not(.empty).active'

        page.should have_css 'span.field-translation', text: article.translation_for(:it).title
      end

    end

    scenario 'Switch block translations' do

      # Third table has a block translation element
      within third_table_row do
        page.should have_css 'th', text: 'BODY'
        page.should have_css 'div.field-translation', text: article.body
        tab_link(:it).click # change shown translation
        page.should have_css 'div.field-translation', text: article.translation_for(:it).body
      end

    end

    scenario 'Viewing empty translations' do
      # create empty translations for it
      I18n.with_locale(:de) { article.update_attributes! title: '', body: '' }
      # Reload article page
      visit admin_article_path(article)

      # First row shows default locale with label title
      within first_table_row do
        flag_link(:de).click # change shown translation
        page.should have_css 'span.field-translation.empty', text: 'EMPTY'
      end

      # Third table has a block translation element
      within third_table_row do
        tab_link(:de).click # change shown translation
        page.should have_css 'div.field-translation span.empty', text: 'EMPTY'
      end

    end

  end

end
