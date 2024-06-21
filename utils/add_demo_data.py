import uuid
from datetime import datetime, timedelta
from random import choice, randint, uniform, shuffle

import psycopg2
from faker import Faker
from psycopg2.extras import execute_values
from dotenv import dotenv_values
import psycopg2.extras

# Required for handling UUID objects in PostgreSQL
psycopg2.extras.register_uuid()

# Initialize faker
fake = Faker()

config = dotenv_values('../.env')

# Connect to the database
conn = psycopg2.connect(
    dbname=config['DB_NAME'],
    user=config['DB_USER'],
    password=config['DB_PASSWORD'],
    host='localhost',
    port=5999
)
cur = conn.cursor()

# Function to generate random date
def random_date(start, end):
    return start + timedelta(days=randint(0, (end - start).days))

# Function to generate random boolean
def random_boolean():
    return choice([True, False])

# Function to generate random UUID
def random_uuid():
    return uuid.uuid4()


def base_properties():
    # Shared by all entities 
    return (
        random_uuid(),  # id
        random_uuid(),  # reference_id
        random_boolean(),  # is_deleted
        random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # last_updated
    )

# Insert data into facility table
def populate_facility(n, geographic_zones):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            True,  # active
            fake.unique.ean(length=8),  # code
            fake.sentence(),  # comment
            geographic_zones[randint(0, len(geographic_zones)-1)], # geographic_zone_id
            fake.text(),  # description
            True,  # enabled
            fake.company()  # name
        ))
    execute_values(cur, """
    INSERT INTO facility (id, reference_id, is_deleted, last_updated, active, code, comment, geographic_zone_id, description, enabled, name)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into geographic_level table
def populate_geographic_level(n):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            fake.unique.ean(length=8),  # code
            randint(0, 3),  # level
            fake.city()  # name
        ))
    execute_values(cur, """
    INSERT INTO geographic_level (id, reference_id, is_deleted, last_updated, code, level, name)
    VALUES %s
    """, data)
    return [{'id': x[1], 'level': x[5]} for x in data]

# Insert data into geographic_zone table
def populate_geographic_zone(n, geographic_levels):
    if n<10:
        raise ValueError("At least 10 locations have to be created")

    level_ratio = {
        0: 0.1, 
        1: 0.25,
        2: 0.48,
        3: 1,
    }

    grouped_zones = {
        0: [], 1:[], 2:[], 3:[], 4:[]
    }

    grouped_levels = {
        0: [x for x in geographic_levels if x['level'] == 0],
        1: [x for x in geographic_levels if x['level'] == 1],
        2: [x for x in geographic_levels if x['level'] == 2],
        3: [x for x in geographic_levels if x['level'] == 3],
    }

    data = []
    for i in range(n):
        level = (i/float(n))
        for k, v in level_ratio.items():
            if level<v:
                level = k
                break
        
        add_parent = level>1
        new_row = (
            *base_properties(),
            randint(1000, 1000000),  # catchment_population
            round(uniform(-180.0, 180.0), 5),  # longitude
            round(uniform(-90.0, 90.0), 5),  # latitude
            fake.city(),  # name
            grouped_levels[level][randint(0, len(grouped_levels[level])-1)]['id'],  # level_id
            grouped_zones[level-1][randint(0, len(grouped_zones[level-1])-1)] if add_parent else None  # parent_id
        )
        data.append(new_row)
        grouped_zones[level].append(new_row[1])
    execute_values(cur, """
    INSERT INTO geographic_zone (id, reference_id, is_deleted, last_updated, catchment_population, longitude, latitude, name, level_id, parent_id)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into lot table
def populate_lot(n):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            True,  # active
            fake.unique.ean(length=8),  # code
            random_date(datetime(2024, 1, 1), datetime(2030, 12, 31)),  # expiration_date
            random_date(datetime(2015, 1, 1), datetime(2023, 12, 31))  # manufacture_date
        ))
    execute_values(cur, """
    INSERT INTO lot (id, reference_id, is_deleted, last_updated, active, code, expiration_date, manufacture_date)
    VALUES %s
    """, data)
    return [x[1] for x in data]


# Insert data into user table
def populate_user(n, facilities):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            random_boolean(),  # active
            fake.first_name(),  # first_name
            fake.last_name(),  # last_name
            fake.timezone(),  # timezone
            fake.user_name(),  # username
            True,  # verified
            facilities[randint(0, len(facilities)-1)],  # home_facility_id
            fake.job(),  # job_title
            fake.phone_number()  # phone_number
        ))
    execute_values(cur, """
    INSERT INTO "user" (id, reference_id, is_deleted, last_updated, active, first_name, last_name, timezone, username, verified, home_facility_id, job_title, phone_number)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into program table
def populate_program(n):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            True,  # active
            fake.unique.ean(length=8),  # code
            fake.word(),  # name
            fake.text(),  # description
            random_boolean(),  # period_sskippable
            random_boolean(),  # shown_on_full_supply_tab
            random_boolean(),  # enable_date_physical_stock_count_completed
            random_boolean()  # skipauthorization
        ))
    execute_values(cur, """
    INSERT INTO program (id, reference_id, is_deleted, last_updated, active, code, name, description, period_sskippable, shown_on_full_supply_tab, enable_date_physical_stock_count_completed, skipauthorization)
    VALUES %s
    """, data)
    return [x[1] for x in data]
    
# Insert data into order table
def populate_order(n, facilities, users, programs):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            users[randint(0, len(users)-1)],  # created_by_id
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # created_date
            random_boolean(),  # emergency
            facilities[randint(0, len(facilities)-1)],  # facility_id
            fake.unique.ean(length=8),  # order_code
            programs[randint(0, len(programs)-1)],  # program_id
            round(uniform(100.0, 10000.0), 2),  # quoted_cost
            facilities[randint(0, len(facilities)-1)],  # receiving_facility_id
            facilities[randint(0, len(facilities)-1)],  # requesting_facility_id
            fake.word(),  # status
            facilities[randint(0, len(facilities)-1)],  # supplying_facility_id
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # last_updated_date
            users[randint(0, len(users)-1)]  # last_updater_id
        ))
    execute_values(cur, """
    INSERT INTO "order" (id, reference_id, is_deleted, last_updated, created_by_id, created_date, emergency, facility_id, order_code, program_id, quoted_cost, receiving_facility_id, requesting_facility_id, status, supplying_facility_id, last_updated_date, last_updater_id)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into product table
def populate_product(n):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            fake.unique.ean(length=8),  # code
            fake.word(),  # name
            fake.text(),  # description
            randint(1, 100),  # pack_rounding_threshold
            randint(1, 1000),  # net_content
            random_boolean()  # roundtozero
        ))
    execute_values(cur, """
    INSERT INTO product (id, reference_id, is_deleted, last_updated, code, name, description, pack_rounding_threshold, net_content, roundtozero)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into order_line table
def populate_order_line(n, orders, products):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            orders[randint(0, len(orders)-1)],  # order_id
            products[randint(0, len(products)-1)],  # product_id
            randint(1, 1000),  # ordered_quantity
            randint(1, 1000)  # product_version_number
        ))
    execute_values(cur, """
    INSERT INTO order_line (id, reference_id, is_deleted, last_updated, order_id, product_id, ordered_quantity, product_version_number)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into program_product table
def populate_program_product(n, programs, products):
    data = []
    relevant_programs = programs.copy()
    shuffle(relevant_programs)
    relevant_programs= relevant_programs[:int(n/10)]
    for program in relevant_programs:
        for _ in range(int(n/10)):
            data.append((
                *base_properties(),
                True,  # active
                randint(1, 10),  # doses_per_patient
                program,  # program_id
                products[randint(0, len(products)-1)],  # product_id
                round(uniform(10.0, 1000.0), 2)  # price_per_pack
            ))
    execute_values(cur, """
    INSERT INTO program_product (id, reference_id, is_deleted, last_updated, active, doses_per_patient, program_id, product_id, price_per_pack)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into program_product table
def pupulate_facility_programs(max_per_facility, facilities, programs):
    data = []
    for facility in facilities:
        # Ensure no product duplicates
        programs_facility = programs.copy()
        shuffle(programs_facility)
        for _ in range(randint(1, max_per_facility)):
            data.append((
                *base_properties(),
                facility, 
                programs_facility.pop()
            ))
    execute_values(cur, """
    INSERT INTO supported_program (id, reference_id, is_deleted, last_updated, facility_id, program_id)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into proof_of_delivery table
def populate_proof_of_delivery(n):
    data = []
    statuses = ['SHIPPED', 'DELIVERED', 'CANCELED', 'PENDING']
    for _ in range(n):
        data.append((
            *base_properties(),
            statuses[randint(0, 3)],  # status
            fake.name(),  # delivered_by
            fake.name(),  # received_by
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31))  # received_date
        ))
    execute_values(cur, """
    INSERT INTO proof_of_delivery (id, reference_id, is_deleted, last_updated, status, delivered_by, received_by, received_date)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into proof_of_delivery_line table
def populate_proof_of_delivery_line(n, proofs_of_deliveries, products, lots):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            proofs_of_deliveries[randint(0, len(proofs_of_deliveries)-1)],  # proof_of_delivery_id
            fake.sentence(),  # notes
            randint(1, 1000),  # quantity_accepted
            randint(0, 100),  # quantity_rejected
            products[randint(0, len(products)-1)],  # product_id
            lots[randint(0, len(lots)-1)],  # lot_id
            fake.word(),  # vvm_status
            random_boolean(),  # use_vvw
            random_uuid(),  # rejection_reasen_id
            randint(1, 1000)  # product_version_number
        ))
    execute_values(cur, """
    INSERT INTO proof_of_delivery_line (id,reference_id, is_deleted, last_updated, proof_of_delivery_id, notes, quantity_accepted, quantity_rejected, product_id, lot_id, vvm_status, use_vvw, rejection_reasen_id, product_version_number)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into requisition table
def populate_requisition(n, facilities, programs):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # created_date
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # modified_date
            random_boolean(),  # emergency
            facilities[randint(0, len(facilities)-1)],  # facility_id
            randint(1, 12),  # months_in_period
            programs[randint(0, len(programs)-1)],  # program_id
            facilities[randint(0, len(facilities)-1)],  # supplying_facility_id
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # stock_count_date
            random_boolean()  # report_only
        ))
    execute_values(cur, """
    INSERT INTO requisition (id, reference_id, is_deleted, last_updated, created_date, modified_date, emergency, facility_id, months_in_period, program_id, supplying_facility_id, stock_count_date, report_only)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into requisition_line table
def populate_requisition_line(n, products, requisitions):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            randint(1, 1000),  # adjusted_consumption
            randint(1, 1000),  # approved_quantity
            randint(1, 1000),  # average_consumption
            randint(1, 1000),  # begining_balance
            randint(1, 1000),  # calculated_order_quantity
            round(uniform(1.0, 10.0), 2),  # max_periods_of_stock
            randint(1, 1000),  # max_stock_quantity
            random_boolean(),  # non_full_supply
            randint(1, 1000),  # new_patients_added
            products[randint(0, len(products)-1)],  # product_id
            randint(1, 1000),  # packs_to_ship
            round(uniform(10.0, 1000.0), 2),  # price_per_pack
            randint(1, 1000),  # requested_quantity
            fake.sentence(),  # requested_quantity_explanation
            random_boolean(),  # skipped
            randint(1, 1000),  # stock_on_hand
            randint(1, 10000),  # total
            randint(1, 1000),  # total_consumed_quantity
            round(uniform(100.0, 10000.0), 2),  # total_cost
            randint(1, 1000),  # total_losses_and_adjustments
            randint(1, 1000),  # total_received_quantity
            randint(1, 1000),  # total_stockout_days
            requisitions[randint(0, len(requisitions)-1)],  # requisition_id
            randint(1, 1000),  # ideal_stock_amount
            randint(1, 1000),  # calculated_ordered_quantity_isa
            randint(1, 1000),  # additional_quantity_required
            randint(1, 1000),  # product_version_number
            random_uuid(),  # facility_type_approved_product_id - what is this varaible? 
            randint(1, 1000),  # facility_type_approved_product_version_number
            randint(1, 1000),  # patients_on_treatment_next_month
            randint(1, 10000),  # total_requirement
            randint(1, 1000),  # total_quantity_needed_by_hf
            randint(1, 1000)  # quantity_to_issue
        ))
    execute_values(cur, """
    INSERT INTO requisition_line (id, reference_id, is_deleted, last_updated, adjusted_consumption, approved_quantity, average_consumption, begining_balance, calculated_order_quantity, max_periods_of_stock, max_stock_quantity, non_full_supply, new_patients_added, product_id, packs_to_ship, price_per_pack, requested_quantity, requested_quantity_explanation, skipped, stock_on_hand, total, total_consumed_quantity, total_cost, total_losses_and_adjustments, total_received_quantity, total_stockout_days, requisition_id, ideal_stock_amount, calculated_ordered_quantity_isa, additional_quantity_required, product_version_number, facility_type_approved_product_id, facility_type_approved_product_version_number, patients_on_treatment_next_month, total_requirement, total_quantity_needed_by_hf, quantity_to_issue)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into stock_event table
def populate_stock_event(n, facilities, programs, users):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            fake.unique.ean(length=8),  # document_number
            facilities[randint(0, len(facilities)-1)],  # facility_id
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # processed_date
            programs[randint(0, len(programs)-1)],  # program_id
            fake.text(),  # signature
            users[randint(0, len(users)-1)],  # user_id
            random_boolean(),  # is_showed
            random_boolean()  # is_active
        ))
    execute_values(cur, """
    INSERT INTO stock_event (id, reference_id, is_deleted, last_updated, document_number, facility_id, processed_date, program_id, signature, user_id, is_showed, is_active)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into stock_event_line table
def populate_stock_event_line(n, facilities, lots, products, stocks_events):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(), 
            fake.text(),  # destination_freetext
            facilities[randint(0, len(facilities)-1)],  # destination_id
            lots[randint(0, len(lots)-1)],  # lot_id
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # occured_date
            products[randint(0, len(products)-1)],  # product_id
            randint(1, 1000),  # quantity
            fake.sentence(),  # reason_freetext
            random_uuid(),  # reason_id
            fake.text(),  # source_freetext
            random_uuid(),  # source_id
            stocks_events[randint(0, len(stocks_events)-1)]  # stock_event_id
        ))
    execute_values(cur, """
    INSERT INTO stock_event_line (id, reference_id, is_deleted, last_updated, destination_freetext, destination_id, lot_id, occured_date, product_id, quantity, reason_freetext, reason_id, source_freetext, source_id, stock_event_id)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into stock_card table
def populate_stock_card(n, facilities, lots, products, programs, events):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            facilities[randint(0, len(facilities)-1)],  # facility_id
            lots[randint(0, len(lots)-1)],  # lot_id
            products[randint(0, len(products)-1)],  # product_id
            programs[randint(0, len(programs)-1)],  # program_id
            events[randint(0, len(events)-1)],  # origin_event_id
            random_boolean(),  # is_showed
            random_boolean()  # is_active
        ))
    execute_values(cur, """
    INSERT INTO stock_card (id, reference_id, is_deleted, last_updated, facility_id, lot_id, product_id, program_id, origin_event_id, is_showed, is_active)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into stock_card_line table
def populate_stock_card_line(n, users, stock_events, stocks_cards):
    data = []
    new_lines = []
    for _ in range(n):
        new_line = (
            *base_properties(),
            fake.text(),  # destination_freetext
            fake.unique.ean(length=8),  # destination_number
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # occured_date
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # processed_date
            randint(1, 1000),  # quantity
            fake.sentence(),  # reason_freetext
            fake.text(),  # signature
            fake.text(),  # source_freetext
            users[randint(0, len(users)-1)],  # user_id
            stock_events[randint(0, len(stock_events)-1)], # new_lines[randint(0, len(new_lines)-1)] if random_boolean() and len(new_lines)>0 else None ,  # origin_event_id
            stocks_cards[randint(0, len(stocks_cards)-1)]  # stock_card_id
        )

        data.append(new_line)
        new_lines.append(new_line[0])
    execute_values(cur, """
    INSERT INTO stock_card_line (id, reference_id, is_deleted, last_updated, destination_freetext, destination_number, occured_date, processed_date, quantity, reason_freetext, signature, source_freetext, user_id, origin_event_id, stock_card_id)
    VALUES %s
    """, data)
    return [x[1] for x in data]

# Insert data into stock_on_hand table
def populate_stock_on_hand(n, stock_cards):
    data = []
    for _ in range(n):
        data.append((
            *base_properties(),
            randint(1, 1000),  # stock_on_hand
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31)),  # occured_date
            stock_cards[randint(0, len(stock_cards)-1)],  # stock_card_id
            random_date(datetime(2020, 1, 1), datetime(2023, 12, 31))  # processed_date
        ))
    execute_values(cur, """
    INSERT INTO stock_on_hand (id,reference_id, is_deleted, last_updated, stock_on_hand, occured_date, stock_card_id, processed_date)
    VALUES %s
    """, data)
    return [x[1] for x in data]




# Populate the tables with data
print("Populating database...")

georgapinc_levels = populate_geographic_level(100)  
geographic_zones = populate_geographic_zone(500, georgapinc_levels)  
print("Geo zones and levels added.")

facilities = populate_facility(2000, geographic_zones)  
print("Facilities added.")

lots=populate_lot(1000)  
print("LOTs added.")

users=populate_user(100, facilities)  
print("Users added.")

programs=populate_program(100)  
print("Programs added.")

orders=populate_order(2500, facilities, users, programs)  
print("Oders added.")

products=populate_product(500)  
print("Facilities added.")

order_lines=populate_order_line(5000, orders, products)  
print("Order Lines added.")

program_products=populate_program_product(1000, programs, products)  
print("Program products added.")

supported_programs = pupulate_facility_programs(20, facilities, programs)
print("Facilities programs added")

pods = populate_proof_of_delivery(500)  
pods_lines = populate_proof_of_delivery_line(800, pods, products, lots)  
print("Proof of Delivery added.")

requisitions = populate_requisition(1000, facilities, programs)  
requisitions_lines = populate_requisition_line(2000, products, requisitions)  
print("Requisitions added.")

stock_events = populate_stock_event(500, facilities, programs, users)  
stock_events_lines = populate_stock_event_line(2000, facilities, lots, products, stock_events)  
print("Stock Events added.")

stock_cards = populate_stock_card(1000, facilities, lots, products, programs, stock_events)  
stock_cards_lines = populate_stock_card_line(2000, users, stock_events, stock_cards)  
print('Stock Cards Added')

populate_stock_on_hand(200, stock_cards)  
print("Stock on hand added.")


# Commit the transaction
conn.commit()

# Close the connection
cur.close()
conn.close()
