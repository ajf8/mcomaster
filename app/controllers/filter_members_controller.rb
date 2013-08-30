class FilterMembersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    render json: FilterMember.all.to_json
  end
  
  def show
    render json: FilterMember.find(params[:id]).to_json
  end
  
  def create
    render json: FilterMember.create(params.slice(:term, :term_key, :term_operator, :filtertype, :filter_id))
  end
  
  def destroy
    render json: FilterMember.find(params[:id]).destroy()
  end
end
