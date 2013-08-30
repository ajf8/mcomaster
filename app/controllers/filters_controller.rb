class FiltersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    render json: Filter.all.to_json(:include => :filter_members)
  end
  
  def show
    render json: Filter.find(params[:id])
  end
  
  def create
    f = Filter.new
    unless params[:filter_members_attributes].nil?
      f.filter_members_attributes = params[:filter_members_attributes]
    end
    f.name = params[:name]
    f.save() 
    render json: f.to_json(:include => :filter_members)
  end
  
  def destroy
    render json: Filter.find(params[:id]).destroy()
  end
  
  def update
    model = Filter.find(params[:id])
    unless params[:filter_members_attributes].nil?
      model.filter_members_attributes = params[:filter_members_attributes]
    end
    model.name = params[:name]
    model.save()
    render json: model.to_json(:include => :filter_members)
  end
end
