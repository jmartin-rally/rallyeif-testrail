require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/testrail_spec_helper'

include TestRailSpecHelper
include YetiTestUtils

describe "Given configuration in the TestRail section" do
  before(:all) do
    # add code here...
    
    # Nice for debugging:
    #trc = testrail_connect(TestRailSpecHelper::TESTRAIL_STATIC_CONFIG)
    #puts "Our TestRail connection contains:"
    #pp trc
  end

  it "(1), should successfully load basic config settings " do
    connection = testrail_connect(TestRailSpecHelper::TESTRAIL_STATIC_CONFIG)
    expect(connection.artifact_type).to be(TestConfig::TR_ARTIFACT_TYPE.downcase.to_sym)
    expect(connection.rally_story_field_for_plan_id).to be_nil
  end
  
  it "(1a), should successfully load config settings for use with post action AssociateWithStoryByRallyField " do
    connection = testrail_connect(TestRailSpecHelper::TESTRAIL_STORY_FIELD_TO_ASSOCIATE_PLAN_CONFIG)
    expect(connection.rally_story_field_for_plan_id).to eq(TestConfig::TR_RALLY_FIELD_TO_HOLD_PLAN_ID)
  end
  
  it "(2), should successfully validate a basic config file " do
    connection = testrail_connect(TestRailSpecHelper::TESTRAIL_STATIC_CONFIG)
    expect(connection.validate).to be(true)
  end
  
  it "(3), should successfully verify existence of fields " do
    connection = testrail_connect(TestRailSpecHelper::TESTRAIL_STATIC_CONFIG)
    expect( connection.field_exists?(TestConfig::TR_ID_FIELD) ).to be(true)
    expect( connection.field_exists?('custom_' + TestConfig::TR_EXTERNAL_ID_FIELD) ).to be(true)
    expect( connection.field_exists?(TestConfig::TR_EXTERNAL_ID_FIELD) ).to be(true)
    expect( connection.field_exists?(:title) ).to be(true)
  end
  
  it "(4), should reject missing required fields" do
    expect { testrail_connect(TestRailSpecHelper::TESTRAIL_MISSING_ARTIFACT_CONFIG) }.to raise_error(/ArtifactType must not be null/)
    expect { testrail_connect(TestRailSpecHelper::TESTRAIL_MISSING_URL_CONFIG) }.to raise_error(/Url must not be null/)
  end
  
  it "(5), should reject invalid artifact types" do
    fred_artifact_config = YetiTestUtils::modify_config_data(
                            TestRailSpecHelper::TESTRAIL_STATIC_CONFIG,   #1 CONFIG  - The config file to be augmented
                            "TestRailConnection",                         #2 SECTION - XML element of CONFIG to be augmented
                            "ArtifactType",                               #3 NEWTAG  - New tag name in reference to REFTAG
                            "Fred",                                       #4 VALUE   - New value to put into NEWTAG
                            "replace",                                    #5 ACTION  - [before, after, replace, delete]
                            "ArtifactType")                               #6 REFTAG  - Existing tag in SECTION
    connection = testrail_connect(fred_artifact_config)
    expect { connection.validate }.to raise_error(/Unrecognize value for <ArtifactType>/)
  end
  
  it "(6), should be OK with tags named <ExternalEndUserIDField>, <CrosslinkUrlField> and <IDField>" do
    # Checking <ExternalEndUserIDField>
    connection = testrail_connect(TestRailSpecHelper::TESTRAIL_EXTERNAL_FIELDS_CONFIG)
    expect(connection.external_end_user_id_field).to be(TestConfig::TR_EXTERNAL_EU_ID_FIELD.to_sym)
    expect(connection.external_item_link_field).to be(TestConfig::TR_CROSSLINK_FIELD.to_sym)
    expect(connection.id_field).to be(TestConfig::TR_ID_FIELD.to_sym)
  end
  
  it "(7), should be OK with missing <ExternalEndUserIDField>, <CrosslinkUrlField> and <IDField>" do
    # Checking <ExternalEndUserIDField>
    connection = testrail_connect(TestRailSpecHelper::TESTRAIL_STATIC_CONFIG)
    expect(connection.external_end_user_id_field).to be(nil)
    expect(connection.external_item_link_field).to be(nil)
    expect(connection.id_field).to be(nil)
  end
  
  it "should validate special fields" do
    config_testresult = YetiTestUtils::modify_config_data(
      TestRailSpecHelper::TESTRAIL_STATIC_CONFIG, #1 CONFIG  - The config file to be augmented
      "TestRailConnection",                       #2 SECTION - XML element of CONFIG to be augmented
      "ArtifactType",                             #3 NEWTAG  - New tag name in reference to REFTAG
      'TestResult',                               #4 VALUE   - New value to put into NEWTAG
      "replace",                                  #5 ACTION  - [before, after, replace, delete]
      "ArtifactType")                             #6 REFTAG  - Existing tag in SECTION
    connection_testresult = testrail_connect(config_testresult)
    expect( connection_testresult.field_exists?(:_testcase) ).to eq(true)

  end
   
end