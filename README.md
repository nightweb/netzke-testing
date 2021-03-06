# Netzke Testing

This gem helps with development and testing of Netzke components. In parcticular, it helps you with:

  * isolated component development
  * client-side testing of components with Mocha and Expect.js

Usage:

    gem 'netzke_testing'

## Isolated component development

The gem implements a Rails engine, which (in development and test environments only) adds a route to load your
application's Netzke components individually, which can be useful for isolated development.  Example (say, we have a
UserGrid component defined):

    http://localhost:3000/netzke/components/UserGrid

This will load a view with UserGrid occupying the available window width, with default height of 400px. You can change
the height by providing the `height` parameter in the URL:

    http://localhost:3000/netzke/components/UserGrid?height=600

## Testing components with Mocha and Expect.js

Place the Mocha specs (written in Coffeescript) for your components inside `spec/features/javascripts` folder. An
example spec may look like this (in `spec/features/javascripts/user_grid.js.coffee`):

    describe 'UserGrid', ->
      it 'shows proper title', ->
        grid = Ext.ComponentQuery.query('panel[id="user_grid"]')[0]
        expect(grid.getHeader().title).to.eql 'Test component'

This spec can be run by appending the `spec` parameter to the url:

    http://localhost:3000/netzke/components/UserGrid?spec=user_grid

Specs can be structured into directories. For example, let's say we have a namescope for admin components:

    class Admin::UserGrid < Netzke::Basepack::Grid
    end

It makes sense to put the corresponding specs in `spec/features/javascripts/admin/user_grid.js.coffee`. In this case,
   the URL to run the Mocha specs will be:

    http://localhost:3000/netzke/components/UserGrid?spec=admin/user_grid

## Mocha spec helpers

The gem provides a number of helpers that may help you writing less code and make your specs look something like this:

    describe 'UserGrid', ->
      it 'allows instant removing of all users with a single button click', (done) ->
        click button 'Remove all'
        wait ->
          expectToSee header 'Empty'
          done()

In order to enable these helpers, add the following line somewhere in your `RSpec.configure` block:

    RSpec.configure do |config|
      Netzke::Testing.rspec_init(config)
      # ...
    end

Keep in mind the following:

  * the current set of helpers is in flux, and may be drastically changed sooner than you may expect
  * the helpers directly pollute the global (`window`) namespace; if you decide you're better off without provided
  helpers, specify 'no-helpers=true' as an extra URL parameter

See the [source
code](https://github.com/netzke/netzke-testing/tree/master/app/assets/javascripts/netzke/testing/helpers) for currently
implemented helpers (TODO: document them). Also, refer to other Netzke gems source code (like netzke-core and
netzke-basepack) to see examples using the helpers.

## Testing with selenium webdriver

Generate the `netzke_mocha_spec.rb` file that will automatically run the specs that follow a certain naming convention:

    rails g netzke_testing

This spec will pick up all the `*_spec.js.coffee` files from `spec/features/javascripts` folder and generate an `it`
clause for each of them. Let's say we want to create the spec for UserGrid. For this we name the spec file
`spec/features/javascripts/user_grid_spec.js.coffee`. And the other way around: when `netzke_mocha_spec.rb` finds a file
called `spec/features/javascripts/order_grid_spec.js.coffee`, it'll assume existance of `OrderGrid` component that
should be tested.

## Mixing client- and server-side testing code

Often we want to run some Ruby code before running the Mocha spec (e.g. to seed some test data using factories), or
after (e.g. to assert changes in the database). In this case you can create a RSpec spec that uses the `run_mocha_spec`
helper provided by the `netzke_testing` gem. Here's an example (in `spec/user_grid_spec.rb`):

    require 'spec_helper'
    feature GridWithDestructiveButton do
      it 'allows instant removing of all records with a single button click', js: true do
        10.times { FactoryGirl.create :user }
        User.count.should == 10
        run_mocha_spec 'grid_with_destructive_button'
        User.count.should == 0
      end
    end

The `run_mocha_spec` here will run a Mocha spec from `spec/grid_with_destructive_button.js.coffee`.

You can explicitely specify a component to run the spec on (in order to override the convention):

    run_mocha_spec 'grid_with_destructive_button', component: 'UserGrid'

---
Copyright (c) 2008-2014 [Max Gorin](https://twitter.com/uptomax), released under the MIT license (see LICENSE).

**Note** that Ext JS is licensed [differently](http://www.sencha.com/products/extjs/license/), and you may need to
purchase a commercial license in order to use it in your projects!
