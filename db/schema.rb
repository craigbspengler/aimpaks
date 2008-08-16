# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 2) do

  create_table "invoice_headers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "format_code",          :limit => 50,                                 :default => ""
    t.string   "invoice_mode",         :limit => 1,                                  :default => "N"
    t.string   "document_title",       :limit => 50,                                 :default => ""
    t.string   "document_number",      :limit => 50,                                 :default => ""
    t.string   "proforma_alert",       :limit => 50,                                 :default => ""
    t.string   "bill_name",            :limit => 50,                                 :default => ""
    t.string   "bill_add1",            :limit => 50,                                 :default => ""
    t.string   "bill_add2",            :limit => 50,                                 :default => ""
    t.string   "bill_add3",            :limit => 50,                                 :default => ""
    t.string   "ship_name",            :limit => 50,                                 :default => ""
    t.string   "ship_add1",            :limit => 50,                                 :default => ""
    t.string   "ship_add2",            :limit => 50,                                 :default => ""
    t.string   "ship_add3",            :limit => 50,                                 :default => ""
    t.string   "invoice",              :limit => 50,                                 :default => ""
    t.date     "date_shipped"
    t.string   "reference",            :limit => 50,                                 :default => ""
    t.string   "workorder",            :limit => 50,                                 :default => ""
    t.date     "date_ordered"
    t.string   "terms",                :limit => 50,                                 :default => ""
    t.string   "account",              :limit => 50,                                 :default => ""
    t.string   "ship_via",             :limit => 50,                                 :default => ""
    t.string   "taken_by",             :limit => 50,                                 :default => ""
    t.decimal  "subtotal_material",                   :precision => 10, :scale => 2, :default => 0.0
    t.string   "tax_number",           :limit => 50,                                 :default => ""
    t.decimal  "invoice_total",                       :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "subtotal_labor",                      :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "tax_amount",                          :precision => 10, :scale => 2, :default => 0.0
    t.string   "deposit_type",         :limit => 50,                                 :default => ""
    t.decimal  "total_deposit_amount",                :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "subtotal_invoice",                    :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "subtotal_shipping",                   :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "balance_due",                         :precision => 10, :scale => 2, :default => 0.0
    t.string   "footnote",             :limit => 100,                                :default => ""
  end

  add_index "invoice_headers", ["invoice"], :name => "fk_invoice_headers_by_invoice"

  create_table "invoice_lines", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_header_id",  :limit => 10
    t.integer  "position",           :limit => 10
    t.string   "line_mode",          :limit => 10,                                :default => "part"
    t.decimal  "part_ordered",                     :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "part_shipped",                     :precision => 10, :scale => 2, :default => 0.0
    t.string   "part_number",        :limit => 50,                                :default => ""
    t.string   "part_sku_um",        :limit => 50,                                :default => ""
    t.string   "part_description",   :limit => 50,                                :default => ""
    t.string   "part_um",            :limit => 50,                                :default => ""
    t.decimal  "part_unit_price",                  :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "part_discount",                    :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "part_net_price",                   :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "part_extension",                   :precision => 10, :scale => 2, :default => 0.0
    t.string   "delivery_area_code", :limit => 50,                                :default => ""
    t.string   "delivery_exchange",  :limit => 50,                                :default => ""
    t.string   "delivery_number",    :limit => 50,                                :default => ""
    t.string   "delivery_contact",   :limit => 50,                                :default => ""
    t.string   "delivery_special0",  :limit => 50,                                :default => ""
    t.string   "delivery_special1",  :limit => 50,                                :default => ""
    t.date     "deposit_received"
    t.string   "deposit_source",     :limit => 50,                                :default => ""
    t.decimal  "deposit_amount",                   :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "labor_ordered",                    :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "labor_shipped",                    :precision => 10, :scale => 2, :default => 0.0
    t.string   "labor_sku",          :limit => 50,                                :default => ""
    t.decimal  "labor_unit_list",                  :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "labor_discount",                   :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "labor_unit_price",                 :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "labor_extension",                  :precision => 10, :scale => 2, :default => 0.0
    t.string   "body_text",          :limit => 50,                                :default => ""
  end

  add_index "invoice_lines", ["invoice_header_id"], :name => "fk_invoice_lines_to_headers"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
