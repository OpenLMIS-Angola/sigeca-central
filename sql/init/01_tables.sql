-- Facility table
CREATE TABLE "facility" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN,
    code TEXT,
    comment TEXT,
    geographic_zone_id UUID, 
    description TEXT,
    enabled BOOLEAN,
    name TEXT
);

CREATE INDEX idx_facility_reference_id ON "facility" (reference_id);

-- Geographic Level table
CREATE TABLE "geographic_level" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    code TEXT,
    level INTEGER,
    name TEXT
);

CREATE INDEX idx_geographic_level_reference_id ON "geographic_level" (reference_id);

-- Geographic Zone table
CREATE TABLE "geographic_zone" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    catchment_population INTEGER,
    longitude NUMERIC(8, 5),
    latitude NUMERIC(8, 5),
    name TEXT,
    level_id UUID,
    parent_id UUID
);

CREATE INDEX idx_geographic_zone_reference_id ON "geographic_zone" (reference_id);

-- Lot table
CREATE TABLE "lot" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE ,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN,
    code TEXT,
    expiration_date DATE,
    manufacture_date DATE
);

CREATE INDEX idx_lot_reference_id ON "lot" (reference_id);

-- Order table
CREATE TABLE "order" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by_id UUID,
    created_date DATE,
    emergency BOOLEAN,
    facility_id UUID,
    order_code TEXT,
    program_id UUID,
    quoted_cost DECIMAL(19, 2),
    receiving_facility_id UUID,
    requesting_facility_id UUID,
    status TEXT,
    supplying_facility_id UUID,
    last_updated_date DATE,
    last_updater_id UUID
);

CREATE INDEX idx_order_reference_id ON "order" (reference_id);

-- Order Line table
CREATE TABLE "order_line" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    order_id UUID,
    product_id UUID,
    ordered_quantity BIGINT,
    product_version_number BIGINT
);

CREATE INDEX idx_order_line_reference_id ON "order_line" (reference_id);

-- Product table
CREATE TABLE "product" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    code TEXT,
    name TEXT,
    description TEXT,
    pack_rounding_threshold BIGINT,
    net_content BIGINT,
    roundtozero BOOLEAN
);

CREATE INDEX idx_product_reference_id ON "product" (reference_id);

-- Program table
CREATE TABLE "program" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN,
    code TEXT,
    name TEXT,
    description TEXT,
    period_sskippable BOOLEAN,
    shown_on_full_supply_tab BOOLEAN,
    enable_date_physical_stock_count_completed BOOLEAN,
    skipauthorization BOOLEAN	
);

CREATE INDEX idx_program_reference_id ON "program" (reference_id);

-- Program Product table
CREATE TABLE "program_product" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN,
    doses_per_patient INTEGER,
    program_id UUID,
    product_id UUID,
    price_per_pack DECIMAL(19, 2)
);

CREATE INDEX idx_program_product_reference_id ON "program_product" (reference_id);

-- Proof Of Delivery table
CREATE TABLE "proof_of_delivery" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status TEXT,
    delivered_by TEXT,
    received_by TEXT,
    received_date DATE
);

CREATE INDEX idx_proof_of_delivery_reference_id ON "proof_of_delivery" (reference_id);

-- Proof Of Delivery Line table
CREATE TABLE "proof_of_delivery_line" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    proof_of_delivery_id UUID,
    notes TEXT,
    quantity_accepted INTEGER,
    quantity_rejected INTEGER,
    product_id UUID,
    lot_id UUID,
    vvm_status TEXT,
    use_vvw BOOLEAN,
    rejection_reasen_id UUID,
    product_version_number BIGINT
);

CREATE INDEX idx_proof_of_delivery_line_reference_id ON "proof_of_delivery_line" (reference_id);

-- Requisition table
CREATE TABLE "requisition" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_date DATE,
    modified_date DATE,
    emergency BOOLEAN,
    facility_id UUID,
    months_in_period INTEGER,
    program_id UUID,
    supplying_facility_id UUID,
    stock_count_date DATE,
    report_only BOOLEAN
);

CREATE INDEX idx_requisition_reference_id ON "requisition" (reference_id);

-- Requisition Line table
CREATE TABLE "requisition_line" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    adjusted_consumption INTEGER,
    approved_quantity INTEGER,
    average_consumption INTEGER,
    begining_balance INTEGER,
    calculated_order_quantity INTEGER,
    max_periods_of_stock DECIMAL(19, 2),
    max_stock_quantity INTEGER,
    non_full_supply BOOLEAN,
    new_patients_added INTEGER,
    product_id UUID,
    packs_to_ship BIGINT,
    price_per_pack DECIMAL(19, 2),
    requested_quantity INTEGER,
    requested_quantity_explanation TEXT,
    skipped BOOLEAN,
    stock_on_hand INTEGER,
    total INTEGER,
    total_consumed_quantity INTEGER,
    total_cost DECIMAL(19, 2),
    total_losses_and_adjustments INTEGER,
    total_received_quantity INTEGER,
    total_stockout_days INTEGER,
    requisition_id UUID,
    ideal_stock_amount INTEGER,
    calculated_ordered_quantity_isa INTEGER,
    additional_quantity_required INTEGER,
    product_version_number BIGINT,
    facility_type_approved_product_id UUID,
    facility_type_approved_product_version_number BIGINT,
    patients_on_treatment_next_month INTEGER,
    total_requirement INTEGER,
    total_quantity_needed_by_hf INTEGER,
    quantity_to_issue INTEGER,
    converted_quantity_to_issue INTEGER
);

CREATE INDEX idx_requisition_line_reference_id ON "requisition_line" (reference_id);

-- Stock Card table
CREATE TABLE "stock_card" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    facility_id UUID,
    lot_id UUID,
    product_id UUID,
    program_id UUID,
    origin_event_id UUID,
    is_showed BOOLEAN,
    is_active BOOLEAN
);

CREATE INDEX idx_stock_card_reference_id ON "stock_card" (reference_id);

-- Stock Card Line table
CREATE TABLE "stock_card_line" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    destination_freetext TEXT,
    destination_number TEXT,
    occured_date DATE,
    processed_date DATE,
    quantity INTEGER,
    reason_freetext TEXT,
    signature TEXT,
    source_freetext TEXT,
    user_id UUID,
    origin_event_id UUID,
    stock_card_id UUID
);

CREATE INDEX idx_stock_card_line_reference_id ON "stock_card_line" (reference_id);

-- Stock Event table
CREATE TABLE "stock_event" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    document_number TEXT,
    facility_id UUID,
    processed_date DATE,
    program_id UUID,
    signature TEXT,
    user_id UUID,
    is_showed BOOLEAN,
    is_active BOOLEAN
);

CREATE INDEX idx_stock_event_reference_id ON "stock_event" (reference_id);

-- Stock Event Line table
CREATE TABLE "stock_event_line" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    destination_freetext TEXT,
    destination_id UUID,
    lot_id UUID,
    occured_date DATE,
    product_id UUID,
    quantity INTEGER,
    reason_freetext TEXT,
    reason_id UUID,
    source_freetext TEXT,
    source_id UUID,
    stock_event_id UUID
);

CREATE INDEX idx_stock_event_line_reference_id ON "stock_event_line" (reference_id);

-- Stock On Hand table
CREATE TABLE "stock_on_hand" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    stock_on_hand INTEGER,
    occured_date DATE,
    stock_card_id UUID,
    processed_date DATE
);

CREATE INDEX idx_stock_on_hand_reference_id ON "stock_on_hand" (reference_id);

-- Supported programs
CREATE TABLE "supported_program" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    facility_id UUID,
    program_id UUID
);

CREATE INDEX idx_supported_program_reference_id ON "supported_program" (reference_id);

-- User table
CREATE TABLE "user" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN,
    first_name TEXT,
    last_name TEXT,
    timezone TEXT,
    username TEXT,
    verified BOOLEAN,
    home_facility_id UUID,
    job_title TEXT,
    phone_number TEXT
);

CREATE INDEX idx_user_reference_id ON "user" (reference_id);

-- Mapa Sanitario

-- Facility table
CREATE TABLE ms.facility (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    name TEXT,
    code TEXT,
    acronym TEXT,
    category TEXT,
    ownership TEXT,
    management TEXT,
    municipality TEXT,
    province TEXT,
    is_operational BOOLEAN,
    latitude TEXT,
    longitude TEXT
);

-- Service table
CREATE TABLE ms.service (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    code TEXT,
    name TEXT
);

-- FacilityService table
CREATE TABLE ms.facility_service (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id UUID UNIQUE,
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    facility_id UUID,
    service_id UUID
);

-- SIGECA Central

-- User table
CREATE TABLE sigeca."user" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    is_deleted BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    username TEXT,
    password_hash TEXT
);
