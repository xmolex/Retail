CREATE TABLE barcodes
(
    id serial,
    inn bigint,
    type smallint,
    barcode character varying(30),
    CONSTRAINT barcodes_pkey PRIMARY KEY (inn,type,barcode)
);

CREATE TABLE users
(
    id serial,
    is_active boolean DEFAULT true,
    account character varying(100),
    pw character varying(100),
    salt character varying(100),
    last_auth timestamp without time zone,
    CONSTRAINT users_pkey PRIMARY KEY (id)
);