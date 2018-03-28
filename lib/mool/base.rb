module Mool
  class Base
    def attrs
      Hash[instance_variables.collect do |attr|
             [attr.to_s.delete(':@').to_sym,
              instance_variable_get(attr)]
           end]
    end
  end
end
