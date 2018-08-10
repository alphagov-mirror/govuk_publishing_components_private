require 'action_view'

module GovukPublishingComponents
  module Presenters
    class ButtonHelper
      attr_reader :href, :text, :title, :info_text, :rel, :data_attributes,
        :start, :margin_bottom

      def initialize(local_assigns)
        @href = local_assigns[:href]
        @text = local_assigns[:text]
        @title = local_assigns[:title]
        @info_text = local_assigns[:info_text]
        @rel = local_assigns[:rel]
        @data_attributes = local_assigns[:data_attributes]
        @start = local_assigns[:start]
        @margin_bottom = local_assigns[:margin_bottom]
      end

      def link?
        href.present?
      end

      def html_options
        options = { class: css_classes }
        options[:role] = "button" if link?
        options[:type] = "submit" unless link?
        options[:rel] = rel if rel
        options[:data] = data_attributes if data_attributes
        options[:title] = title if title
        options
      end

    private

      def css_classes
        classes = %w(gem-c-button govuk-button)
        classes << "govuk-button--start" if start
        classes << "gem-c-button--bottom-margin" if margin_bottom
        classes.join(" ")
      end
    end
  end
end
