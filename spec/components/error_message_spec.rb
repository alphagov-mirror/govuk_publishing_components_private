require 'rails_helper'

describe "Error message", type: :view do
  def component_name
    "error_message"
  end

  it "renders error message" do
    render_component(text: "Please enter your National Insurance number")

    assert_select(".govuk-error-message", text: "Error: Please enter your National Insurance number")
  end

  it "renders error message with a given ID" do
    render_component(text: "Please enter your National Insurance number", id: "error_id")

    assert_select(".govuk-error-message[id=error_id]")
  end

  it "escapes HTML in items and allows HTML safe strings" do
    render_component(items: [
      { text: "Error where HTML is <strong>escaped</strong>" },
      { text: "Error where HTML is <strong>maintained</strong>".html_safe },
    ])

    assert_select(".govuk-error-message", html: %r{Error where HTML is &lt;strong&gt;escaped&lt;/strong&gt;})
    assert_select(".govuk-error-message", html: %r{Error where HTML is <strong>maintained</strong>})
  end
end
