class BuildingsController < ApplicationController

  def index
    file = File.read(Rails.public_path + "building_geo.json")
    geo_data = JSON.parse(file)
    @rooms = Room.all
    if params[:StudentAccessible]
      @rooms = @rooms.where("facilities LIKE '%ADA-Student Accessible%'")
    end
    if params[:Whiteboard]
      @rooms = @rooms.where("facilities LIKE '%Board-White%' OR facilities LIKE '%Board-Front%'")
    end
    if params[:AV]
      @rooms = @rooms.where("facilities LIKE '%AV%'")
    end
    if params.key?(:room_type)
      if params[:room_type] != "Any"
        @rooms = @rooms.where(:misc => params[:room_type])
      end
    end
    building_ids = Set.new
    @rooms.select(:building_id).group(:building_id).each do |data|
      building_ids.add(data.building_id)
    end
    puts building_ids
    update_features = []
    geo_data["features"].each do |building|
      if building_ids.include? building["id"]
        update_features.push building
      end
    end
    geo_data["features"] = update_features
    File.open(Rails.public_path + "updated_building_geo.json","w") do |f|
      f.write(geo_data.to_json)
    end 
  end

  def search
  end
  
  def show
    building_id = params[:id] 
    @building = Building.find_by_id(building_id)
    
    if @building.blank?
      flash[:notice] = "This building does not exist."
      redirect_to buildings_path
    end
    
    @rooms = Room.where(:building_id => building_id)
    @rooms.each do |room|
      if room.misc == nil then room.misc = "N/A" end
      if room.facilities == nil then room.facilities = "N/A" end
    end
  end
  
end
