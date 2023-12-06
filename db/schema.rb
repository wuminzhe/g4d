# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_08_28_142104) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.string "title"
    t.text "body"
    t.string "subject"
    t.integer "user_id", null: false
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "council_motions", force: :cascade do |t|
    t.integer "motion_index"
    t.string "motion_hash"
    t.integer "created_block"
    t.integer "updated_block"
    t.integer "aye_votes"
    t.integer "nay_votes"
    t.integer "status"
    t.integer "threshold"
    t.boolean "executed_success"
    t.string "value"
    t.string "motion_call_module"
    t.string "motion_call_name"
    t.jsonb "motion_call_params"
    t.jsonb "votes"
    t.jsonb "timeline"
    t.integer "network_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "preimage_id"
    t.integer "created_block_spec_version"
    t.integer "created_block_hash"
  end

  create_table "democracy_external_proposals", force: :cascade do |t|
    t.integer "network_id"
    t.integer "council_motion_id"
    t.integer "created_block"
    t.string "preimage_hash"
    t.integer "preimage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_block"
    t.integer "status"
    t.jsonb "timeline"
  end

  create_table "democracy_public_proposals", force: :cascade do |t|
    t.integer "network_id"
    t.integer "proposal_index"
    t.integer "status"
    t.integer "created_block"
    t.integer "updated_block"
    t.string "preimage_hash"
    t.string "value"
    t.integer "seconded_count", default: 0
    t.jsonb "timeline"
    t.integer "preimage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.jsonb "seconds"
    t.jsonb "votes"
    t.string "block_timestamp"
    t.index ["network_id", "proposal_index"], name: "public_proposals_index", unique: true
    t.index ["preimage_hash"], name: "index_democracy_public_proposals_on_preimage_hash"
  end

  create_table "democracy_referendums", force: :cascade do |t|
    t.integer "network_id"
    t.integer "referendum_index"
    t.jsonb "author"
    t.integer "created_block"
    t.integer "updated_block"
    t.integer "preimage_id"
    t.string "preimage_hash"
    t.integer "vote_threshold"
    t.integer "status"
    t.integer "delay"
    t.integer "end"
    t.string "aye_amount", default: "0"
    t.string "nay_amount", default: "0"
    t.string "turnout"
    t.boolean "executed_success"
    t.string "aye_without_conviction", default: "0"
    t.string "nay_without_conviction", default: "0"
    t.jsonb "timeline"
    t.string "call_module"
    t.string "call_name"
    t.integer "block_timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.jsonb "votes"
    t.index ["network_id", "referendum_index"], name: "index_democracy_referendums_on_network_id_and_referendum_index", unique: true
  end

  create_table "discussions", force: :cascade do |t|
    t.string "uuid"
    t.string "title"
    t.text "body"
    t.integer "network_id"
    t.string "first_real_step_type"
    t.string "first_real_step_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id", "first_real_step_type", "first_real_step_key"], name: "index_discussions_on_real_step_key", unique: true
    t.index ["uuid"], name: "index_discussions_on_uuid", unique: true
  end

  create_table "governance_steps", force: :cascade do |t|
    t.integer "governance_id"
    t.integer "real_step_id"
    t.string "real_step_type"
    t.string "real_step_index"
    t.integer "real_step_block"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "seq"
    t.index ["real_step_type", "real_step_index"], name: "index_governance_steps_on_real_step_type_and_real_step_index"
  end

  create_table "governances", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "init_time"
    t.integer "init_block"
    t.integer "init_user_id"
    t.integer "network_id"
    t.integer "preimage_id"
    t.string "uuid"
    t.integer "discussion_id"
  end

  create_table "identities", force: :cascade do |t|
    t.integer "user_id"
    t.integer "network_id"
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "networks", force: :cascade do |t|
    t.string "chain_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subscan"
    t.index ["chain_id"], name: "index_networks_on_chain_id", unique: true
  end

  create_table "preimages", force: :cascade do |t|
    t.integer "network_id"
    t.string "preimage_hash"
    t.integer "created_block"
    t.integer "updated_block"
    t.integer "status"
    t.string "amount"
    t.string "call_module"
    t.string "call_name"
    t.jsonb "call_params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["network_id", "preimage_hash"], name: "index_preimages_on_network_id_and_preimage_hash", unique: true
  end

  create_table "subsquid_events", force: :cascade do |t|
    t.integer "network_id"
    t.string "sid"
    t.string "index"
    t.string "name"
    t.string "pallet_name"
    t.string "event_name"
    t.jsonb "args"
    t.integer "block_height"
    t.string "block_hash"
    t.string "block_timestamp"
    t.integer "block_spec_version"
    t.jsonb "block_events"
    t.string "call_name"
    t.string "call_pallet_name"
    t.string "call_call_name"
    t.jsonb "call_args"
    t.jsonb "call_origin"
    t.string "call_extrinsic_index"
    t.string "call_extrinsic_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id", "pallet_name"], name: "index_subsquid_events_on_network_id_and_pallet_name"
    t.index ["network_id", "sid"], name: "index_subsquid_events_on_network_id_and_sid", unique: true
  end

  create_table "subsquid_indices", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "techcomm_proposals", force: :cascade do |t|
    t.integer "network_id"
    t.integer "proposal_index"
    t.integer "created_block"
    t.integer "updated_block"
    t.integer "aye_votes"
    t.integer "nay_votes"
    t.integer "status"
    t.string "proposal_hash"
    t.integer "threshold"
    t.boolean "executed_success"
    t.string "value"
    t.string "proposal_call_module"
    t.string "proposal_call_name"
    t.jsonb "proposal_call_params"
    t.jsonb "votes"
    t.jsonb "timeline"
    t.integer "preimage_id"
    t.string "preimage_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "treasury_proposals", force: :cascade do |t|
    t.integer "proposal_index"
    t.integer "created_block"
    t.integer "status"
    t.string "reward"
    t.string "reward_extra"
    t.jsonb "beneficiary"
    t.jsonb "timeline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "network_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.datetime "last_seen_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_users_on_address", unique: true
  end

end
