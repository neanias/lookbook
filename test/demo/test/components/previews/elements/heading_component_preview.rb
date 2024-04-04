module Elements
  # Examples of rendering ViewComponent previews using the `ViewComponent::Preview` base class.
  class HeadingComponentPreview < ViewComponent::Preview
    def default
      render Elements::HeadingComponent.new do
        "A heading"
      end
    end
  end
end
