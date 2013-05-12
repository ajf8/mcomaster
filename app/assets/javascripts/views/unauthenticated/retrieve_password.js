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

MCM.Views.Unauthenticated.RetrievePassword = Backbone.Marionette.ItemView.extend({
  template: HandlebarsTemplates["unauthenticated/retrieve_password"],

  events: {
    'submit form': 'retrievePassword'
  },

  initialize: function() {
    this.model = new MCM.Models.UserPasswordRecovery();
    this.modelBinder = new Backbone.ModelBinder();
  },

  onRender: function() {
    this.modelBinder.bind(this.model, this.el);
  },

  retrievePassword: function(e) {
    var self = this,
        el = $(this.el);

    e.preventDefault();

    el.find('input.btn-primary').button('loading');
    el.find('.alert-error').remove();
    el.find('.alert-success').remove();

    this.model.save(this.model.attributes, {
      success: function(userSession, response) {
        el.find('form').prepend(MCM.Helpers.Notifications.success("Instructions for resetting your password have been sent. Please check your email for further instructions."));
        el.find('input.btn-primary').button('reset');
      },
      error: function(userSession, response) {
        el.find('form').prepend(MCM.Helpers.Notifications.error("The email you entered did not match an email in our database."));
        el.find('input.btn-primary').button('reset');
      }
    });
  }
});
