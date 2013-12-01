require 'coffee-script'

class Netzke::TestingController < ApplicationController
  def components
    component_name = params[:class].gsub("::", "_").underscore
    render :inline => "<%= netzke :#{component_name}, :class_name => '#{params[:class]}', :height => #{params[:height] || 400} %>",
           :layout => true
  end

  def specs
    coffee = spec_file(params[:name])
    render text: CoffeeScript.compile(coffee)
  end

  private

  def spec_file(name)
    spec_root = Pathname.new(Netzke::Testing.spec_root || Rails.root)

    path = spec_root.join "spec/javascripts/#{name}_spec.js.coffee"

    if !File.exists?(File.expand_path(path, __FILE__))
      path = spec_root.join "spec/javascripts/#{name}.js.coffee"
    end

    File.read(File.expand_path(path, __FILE__))
  end
end