# acts_as_section_map
# (c) 2008 xibbar(Takeyuki FUJIOKA)
# MIT licence
#
require 'acts_as_section_map'
require 'acts_as_section_map_helper'

ActiveRecord::Base.class_eval do
  include XibbarNet::Acts::SectionMap
end

if Object.const_defined?('ActionView')
  ActionView::Base.send :include, XibbarNet::Acts::SectionMapHelper
end

