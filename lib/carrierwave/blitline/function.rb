module CarrierWave
  module Blitline
    # A Struct class for storing name and params for each function parameter.
    #   See also: ImageVersionFunctionPresenter
    class Function < Struct.new(:name, :params)
    end
  end
end
