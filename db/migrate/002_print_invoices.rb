class PrintInvoices < ActiveRecord::Migration

  def self.up
    
    create_table :invoice_headers, :force => true do |t|
      t.timestamps
      t.column :format_code, :string, :limit => 50, :default => 'GHW'
      t.column :invoice_mode, :string, :limit => 1, :default => 'N'
      t.column :document_title, :string, :limit => 50, :default => ''
      t.column :document_number, :string, :limit => 50, :default => ''
      t.column :proforma_alert, :string, :limit => 50, :default => ''
      t.column :bill_name, :string, :limit => 50, :default => ''
      t.column :bill_add1, :string, :limit => 50, :default => ''
      t.column :bill_add2, :string, :limit => 50, :default => ''
      t.column :bill_add3, :string, :limit => 50, :default => ''
      t.column :ship_name, :string, :limit => 50, :default => ''
      t.column :ship_add1, :string, :limit => 50, :default => ''
      t.column :ship_add2, :string, :limit => 50, :default => ''
      t.column :ship_add3, :string, :limit => 50, :default => ''
      t.column :invoice, :string, :limit => 50, :default => ''
      t.column :date_shipped, :date
      t.column :reference, :string, :limit => 50, :default => ''
      t.column :workorder, :string, :limit => 50, :default => ''
      t.column :date_ordered, :date
      t.column :terms, :string, :limit => 50, :default => ''
      t.column :account, :string, :limit => 50, :default => ''
      t.column :ship_via, :string, :limit => 50, :default => ''
      t.column :taken_by, :string, :limit => 50, :default => ''
      t.column :subtotal_material, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :tax_number, :string, :limit => 50, :default => ''
      t.column :invoice_total, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :subtotal_labor, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :tax_amount, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :deposit_type, :string, :limit => 50, :default => ''
      t.column :total_deposit_amount, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :subtotal_invoice, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :subtotal_shipping, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :balance_due, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :footnote, :string, :limit => 100, :default => ''
    end

    add_index :invoice_headers, :invoice, :name => 'fk_invoice_headers_by_invoice'
      
    create_table :invoice_lines, :force => true do |t|
      t.timestamps
      t.column :invoice_header_id, :integer, :limit => 10
      t.column :position, :integer, :limit => 10
      t.column :line_mode, :string, :limit => 10, :default => 'part'
      t.column :part_ordered, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :part_shipped, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :part_number, :string, :limit => 50, :default => ''
      t.column :part_sku_um, :string, :limit => 50, :default => ''
      t.column :part_description, :string, :limit => 50, :default => ''
      t.column :part_um, :string, :limit => 50, :default => ''
      t.column :part_unit_price, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :part_discount, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :part_net_price, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :part_extension, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :delivery_area_code, :string, :limit => 50, :default => ''
      t.column :delivery_exchange, :string, :limit => 50, :default => ''
      t.column :delivery_number, :string, :limit => 50, :default => ''
      t.column :delivery_contact, :string, :limit => 50, :default => ''
      t.column :delivery_special0, :string, :limit => 50, :default => ''
      t.column :delivery_special1, :string, :limit => 50, :default => ''
      t.column :deposit_received, :date
      t.column :deposit_source, :string, :limit => 50, :default => ''
      t.column :deposit_amount, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :labor_ordered, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :labor_shipped, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :labor_sku, :string, :limit => 50, :default => ''
      t.column :labor_unit_list, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :labor_discount, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :labor_unit_price, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :labor_extension, :decimal, :precision => 10, :scale => 2, :default => 0.0
      t.column :body_text, :string, :limit => 50, :default => ''
    end

    add_index :invoice_lines, :invoice_header_id, :name => 'fk_invoice_lines_to_headers'
    
  end
  
  def self.down
    drop_table :invoice_lines
    drop_table :invoice_headers
  end
  
end
