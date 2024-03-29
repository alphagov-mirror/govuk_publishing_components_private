require "rails_helper"

describe "Contextual sidebar", type: :view do
  def component_name
    "contextual_sidebar"
  end

  it "renders the sidebar" do
    render_component(
      content_item: GovukSchemas::RandomExample.for_schema(frontend_schema: "speech")
    )

    assert_select ".gem-c-contextual-sidebar"
  end
end
