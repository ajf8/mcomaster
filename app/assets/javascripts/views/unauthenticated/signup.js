/* Copyright 2013 ajf http://github.com/ajf8
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
MCM.Views.Unauthenticated = MCM.Views.Unauthenticated || {};

MCM.Views.Unauthenticated.Signup = Backbone.Marionette.ItemView.extend({
  template: HandlebarsTemplates["unauthenticated/signup"],

  events: {
    'submit form': 'signup'
  },

  initialize: function() {
    this.model = new MCM.Models.UserRegistration();
    this.modelBinder = new Backbone.ModelBinder();
  },

  onRender: function() {
    this.modelBinder.bind(this.model, this.el);
  },

  signup: function(e) {

    var self = this,
        el = $(this.el);

    e.preventDefault();

    el.find('input.btn-primary').button('loading');
    el.find('.alert-error').remove();
    el.find('.help-block').remove();
    el.find('.control-group.error').removeClass('error');

    this.model.save(this.model.attributes, {
      success: function(userSession, response) {
        el.find('input.btn-primary').button('reset');
        MCM.currentUser = new MCM.Models.User(response);
        MCM.vent.trigger("authentication:logged_in", MCM.currentUser);
        MCM.vent.trigger("authentication:interactive_logged_in", MCM.currentUser)
      },
      error: function(userSession, response) {
        var result = $.parseJSON(response.responseText);
        el.find('form').prepend(MCM.Helpers.Notifications.error("Unable to complete signup."));
        _(result.errors).each(function(errors,field) {
          $('#'+field+'_group').addClass('error');
          _(errors).each(function(error, i) {
            $('#'+field+'_group .controls').append(MCM.Helpers.FormHelpers.fieldHelp(error));
          });
        });
        el.find('input.btn-primary').button('reset');
      }
    });
  }
});
