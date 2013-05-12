require "spec_helper"

describe McagentsController do
  describe "routing" do

    it "routes to #index" do
      get("/mcagents").should route_to("agents#index")
    end

    it "routes to #show" do
      get("/mcagents/1").should route_to("agents#show", :id => "1")
    end
  end
end
