require 'C:\openstudio-3.9.0\Ruby\openstudio' # Ensure this path is valid for 3.9.0
#require 'C:\openstudio-3.7.0\Ruby\openstudio' # Ensure this path is valid 3.7.0

puts "Script starting..."

# Name of test model
expected_osm_file = "./test_osm_file_hw_39.osm" # 3.9.0
#expected_osm_file = "./test_osm_file_hw_37.osm" # 3.7.0

# Path to test model
expected_osm_model_path = OpenStudio::Path.new(expected_osm_file)

# Attempt to load the model
version_translator = OpenStudio::OSVersion::VersionTranslator.new
model = version_translator.loadModel(expected_osm_model_path)

# Check that model is loaded properly
if model.is_initialized
    model = model.get
    puts "Model loaded successfully."
else
    puts "Failed to load the OSM model from path: #{expected_osm_file}"
end

# Get objects from test model
always_on = model.alwaysOnDiscreteSchedule # Create constant schedule for example
supplemental_htg_coil_hw = model.getCoilHeatingWaters # Supplemental water coil from test model
htg_coil = model.getCoilHeatingDXSingleSpeeds # Heating coil from test model
clg_coil = model.getCoilCoolingDXSingleSpeeds # Cooling coil from test model
fan = model.getFanOnOffs # Fan from test model

# Create a gas supplemental heating coil to test too
supplemental_htg_coil_gas = OpenStudio::Model::CoilHeatingGas.new(model, always_on)

# See if there are any errors when specifying the gas supplemental heating coil
puts "Trying a gas supplemental heating coil..."
begin
    air_to_air_heatpump = OpenStudio::Model::AirLoopHVACUnitaryHeatPumpAirToAir.new(
        model, # model object
        always_on, # schedule object
        fan[0], # fan object
        htg_coil[0], # heating coil object
        clg_coil[0], # cooling coil object
        supplemental_htg_coil_gas # supplemental heating coil object
    )
    puts "Air-to-air heat pump created successfully with a gas supplemental heating coil."
rescue => e
    puts "Error encountered while creating air-to-air heat pump with a gas supplemental heating coil: #{e.message}"
end

# See if there are any errors when specifying the water supplemental heating coil
puts "Trying a water supplemental heating coil..."
begin
    air_to_air_heatpump = OpenStudio::Model::AirLoopHVACUnitaryHeatPumpAirToAir.new(
        model, # model object
        always_on, # schedule object
        fan[0], # fan object
        htg_coil[0], # heating coil object
        clg_coil[0], # cooling coil object
        supplemental_htg_coil_hw[0] # supplemental heating coil object
    )
    puts "Air-to-air heat pump created successfully with a water supplemental heating coil."
rescue => e # This doesn't seem to work given the nature and severity of the error generated as the script terminates before here
    puts "Error encountered while creating air-to-air heat pump with a water supplemental heating coil: #{e.message}"
end

puts "Script finished."