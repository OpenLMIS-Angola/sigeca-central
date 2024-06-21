
-- Facility constraints
ALTER TABLE facility
ADD CONSTRAINT facility_geographic_zone_id_fkey FOREIGN KEY (geographic_zone_id) REFERENCES geographic_zone(reference_id);

-- Geographic Level constraints

-- Geographic Zone constraints
ALTER TABLE geographic_zone
ADD CONSTRAINT geographic_zone_level_id_fkey FOREIGN KEY (level_id) REFERENCES geographic_level(reference_id);

-- ALTER TABLE geographic_zone
-- ADD CONSTRAINT geographic_zone_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES geographic_zone(reference_id);

-- Lot constraints

-- Order constraints

-- Order Line constraints
ALTER TABLE order_line
ADD CONSTRAINT order_line_order_id_fkey FOREIGN KEY (order_id) REFERENCES "order"(reference_id);

-- Product constraints

ALTER TABLE product
ADD CONSTRAINT product_reference_id_version_number_unique UNIQUE (reference_id, version_number);

-- Program constraints

-- Program Product constraints
ALTER TABLE program_product
ADD CONSTRAINT program_product_program_id_fkey FOREIGN KEY (program_id) REFERENCES program(reference_id);

ALTER TABLE program_product
ADD CONSTRAINT program_product_product_id_fkey FOREIGN KEY (product_id, product_version_number) REFERENCES product(reference_id, version_number);

-- Proof Of Delivery constraints

-- Proof Of Delivery Line constraints
ALTER TABLE proof_of_delivery_line
ADD CONSTRAINT proof_of_delivery_line_proof_of_delivery_id_fkey FOREIGN KEY (proof_of_delivery_id) REFERENCES proof_of_delivery(reference_id);

ALTER TABLE proof_of_delivery_line
ADD CONSTRAINT proof_of_delivery_line_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES lot(reference_id);

-- Requisition constraints

-- Requisition Line constraints
ALTER TABLE requisition_line
ADD CONSTRAINT requisition_line_requisition_id_fkey FOREIGN KEY (requisition_id) REFERENCES requisition(reference_id);

-- Stock Card constraints
ALTER TABLE stock_card
ADD CONSTRAINT stock_card_origin_event_id_fkey FOREIGN KEY (origin_event_id) REFERENCES stock_event(reference_id);

-- Stock Card Line constraints
ALTER TABLE stock_card_line
ADD CONSTRAINT stock_card_line_origin_event_id_fkey FOREIGN KEY (origin_event_id) REFERENCES stock_event(reference_id);

ALTER TABLE stock_card_line
ADD CONSTRAINT stock_card_line_stock_card_id_fkey FOREIGN KEY (stock_card_id) REFERENCES stock_card(reference_id);

-- Stock Event constraints

-- Stock Event Line constraints
ALTER TABLE stock_event_line
ADD CONSTRAINT stock_event_line_stock_event_id_fkey FOREIGN KEY (stock_event_id) REFERENCES stock_event(reference_id);

-- Stock On Hand constraints
ALTER TABLE stock_on_hand
ADD CONSTRAINT stock_on_hand_stock_card_id_fkey FOREIGN KEY (stock_card_id) REFERENCES stock_card(reference_id);

-- Supported Program constraints 
ALTER TABLE supported_program
ADD CONSTRAINT supported_program_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES facility(reference_id);

ALTER TABLE supported_program
ADD CONSTRAINT supported_program_program_id_fkey FOREIGN KEY (program_id) REFERENCES program(reference_id);

ALTER TABLE supported_program
ADD CONSTRAINT supported_program_facility_id_program_id_unique UNIQUE (facility_id, program_id);

-- User constraints

ALTER TABLE "user"
ADD CONSTRAINT user_home_facility_id_fkey FOREIGN KEY (home_facility_id) REFERENCES facility(reference_id);

-- Mapa Sanitario

-- Facility constraints

-- Service constraints

-- Facility Service constraints
ALTER TABLE ms.facility_service
ADD CONSTRAINT facility_service_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES ms.facility(id);

ALTER TABLE ms.facility_service
ADD CONSTRAINT facility_service_service_id_fkey FOREIGN KEY (service_id) REFERENCES ms.service(id);

-- SIGECA Central

-- User constrants
