require "rails_helper"

describe "Breadcrumbs", type: :view do
  def component_name
    "breadcrumbs"
  end

  def assert_link_with_text_in(selector, link, text)
    assert_select "#{selector} a[href=\"#{link}\"]", text: text
  end

  it "no error if no parameters passed in" do
    render_component({})
    assert_select ".gem-c-breadcrumbs"
  end

  it "renders a single breadcrumb" do
    render_component(breadcrumbs: [{ title: 'Section', url: '/section' }])

    assert_link_with_text_in('.govuk-breadcrumbs__list-item:first-child', '/section', 'Section')
  end

  it "renders schema data" do
    breadcrumbs = [
      { title: 'Section 1', url: '/section-1' },
      { title: 'Section 2', url: '/section-2' },
      { title: 'Section 3', is_current_page: true },
    ]
    structured_data = GovukPublishingComponents::Presenters::Breadcrumbs.new(breadcrumbs, "/section-3").structured_data
    expect(structured_data["@type"]).to eq("BreadcrumbList")
    expect(structured_data["itemListElement"].first["@type"]).to eq("ListItem")
    expect(structured_data["itemListElement"].first["position"]).to eq(1)
    expect(structured_data["itemListElement"].first["item"]["@id"]).to eq("http://www.dev.gov.uk/section-1")
    expect(structured_data["itemListElement"].first["item"]["name"]).to eq("Section 1")
    expect(structured_data["itemListElement"][1]["item"]["@id"]).to eq("http://www.dev.gov.uk/section-2")
    expect(structured_data["itemListElement"][1]["item"]["name"]).to eq("Section 2")
    expect(structured_data["itemListElement"][2]["item"]["@id"]).to eq("http://www.dev.gov.uk/section-3")
    expect(structured_data["itemListElement"][2]["item"]["name"]).to eq("Section 3")
  end

  it "omits breadcrumb structured data when no url is present" do
    breadcrumbs = [
      { title: 'Section 1', url: '/section-1' },
      { title: 'Section 2' },
    ]
    structured_data = GovukPublishingComponents::Presenters::Breadcrumbs.new(breadcrumbs, "/section-3").structured_data
    expect(structured_data["@type"]).to eq("BreadcrumbList")
    expect(structured_data["itemListElement"].count).to eq(1)
    expect(structured_data["itemListElement"].first["@type"]).to eq("ListItem")
    expect(structured_data["itemListElement"].first["position"]).to eq(1)
    expect(structured_data["itemListElement"].first["item"]["@id"]).to eq("http://www.dev.gov.uk/section-1")
    expect(structured_data["itemListElement"].first["item"]["name"]).to eq("Section 1")
  end

  it "renders all data attributes for tracking" do
    render_component(breadcrumbs: [{ title: 'Section', url: '/section' }])

    expected_tracking_options = {
      dimension28: "1",
      dimension29: "Section"
    }

    assert_select '.gem-c-breadcrumbs[data-module="track-click"]', 1
    assert_select '.govuk-breadcrumbs__list-item:first-child a[data-track-action="1"]', 1
    assert_select '.govuk-breadcrumbs__list-item:first-child a[data-track-label="/section"]', 1
    assert_select '.govuk-breadcrumbs__list-item:first-child a[data-track-category="breadcrumbClicked"]', 1
    assert_select ".govuk-breadcrumbs__list-item:first-child a[data-track-options='#{expected_tracking_options.to_json}']", 1
  end

  it "a link to the homepage has separate tracking data" do
    render_component(breadcrumbs: [{ title: 'Section', url: '/section' }, { title: 'Home', url: '/' }])

    expected_tracking_options = {
        dimension28: "2",
        dimension29: "Section"
    }

    assert_select '.gem-c-breadcrumbs[data-module="track-click"]', 1

    assert_select '.govuk-breadcrumbs__list-item:nth-child(1) a[data-track-action="1"]', 1
    assert_select '.govuk-breadcrumbs__list-item:nth-child(1) a[data-track-label="/section"]', 1
    assert_select '.govuk-breadcrumbs__list-item:nth-child(1) a[data-track-category="breadcrumbClicked"]', 1
    assert_select ".govuk-breadcrumbs__list-item:nth-child(1) a[data-track-options='#{expected_tracking_options.to_json}']", 1

    assert_select '.govuk-breadcrumbs__list-item:nth-child(2) a[data-track-action="homeBreadcrumb"]', 1
    assert_select '.govuk-breadcrumbs__list-item:nth-child(2) a[data-track-label=""]', 1
    assert_select '.govuk-breadcrumbs__list-item:nth-child(2) a[data-track-category="homeLinkClicked"]', 1
    assert_select ".govuk-breadcrumbs__list-item:nth-child(2) a[data-track-options='{}']", 1
  end

  it "tracks the total breadcrumb count on each breadcrumb" do
    breadcrumbs = [
      { title: 'Section 1', url: '/section-1' },
      { title: 'Section 2', url: '/section-2' },
      { title: 'Section 3', url: '/section-3' },
    ]
    render_component(breadcrumbs: breadcrumbs)

    expected_tracking_options = [
      { dimension28: "3", dimension29: "Section 1" },
      { dimension28: "3", dimension29: "Section 2" },
      { dimension28: "3", dimension29: "Section 3" },
    ]

    assert_select ".govuk-breadcrumbs__list-item:nth-child(1) a[data-track-options='#{expected_tracking_options[0].to_json}']", 1
    assert_select ".govuk-breadcrumbs__list-item:nth-child(2) a[data-track-options='#{expected_tracking_options[1].to_json}']", 1
    assert_select ".govuk-breadcrumbs__list-item:nth-child(3) a[data-track-options='#{expected_tracking_options[2].to_json}']", 1
  end

  it "renders a list of breadcrumbs" do
    render_component(breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Section', url: '/section' },
        { title: 'Sub-section', url: '/sub-section' },
      ])

    assert_link_with_text_in('.govuk-breadcrumbs__list-item:first-child', '/', 'Home')
    assert_link_with_text_in('.govuk-breadcrumbs__list-item:first-child + li', '/section', 'Section')
    assert_link_with_text_in('.govuk-breadcrumbs__list-item:last-child', '/sub-section', 'Sub-section')
  end

  it "renders inverted breadcrumbs when passed a flag" do
    render_component(breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Section', url: '/section' },
      ], inverse: true)

    assert_select ".gem-c-breadcrumbs--inverse"
  end

  it "allows the last breadcrumb to be text only" do
    render_component(
      breadcrumbs: [
        { title: 'Topic', url: '/topic' },
        { title: 'Current Page' },
      ]
    )
    assert_select('.govuk-breadcrumbs__list-item:last-child', 'Current Page')
  end
end
