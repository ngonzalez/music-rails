SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE friendly_id_slugs (
    id bigint NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendly_id_slugs_id_seq OWNED BY friendly_id_slugs.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE images (
    id integer NOT NULL,
    release_id integer NOT NULL,
    file_uid character varying NOT NULL,
    file_name character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    thumb_uid character varying,
    thumb_high_uid character varying,
    type character varying
);


--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE images_id_seq OWNED BY images.id;


--
-- Name: m3u_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE m3u_files (
    id integer NOT NULL,
    release_id integer NOT NULL,
    file_uid character varying NOT NULL,
    file_name character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    source character varying
);


--
-- Name: m3u_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE m3u_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: m3u_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE m3u_files_id_seq OWNED BY m3u_files.id;


--
-- Name: releases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE releases (
    id integer NOT NULL,
    name character varying NOT NULL,
    folder character varying,
    last_verified_at timestamp without time zone,
    details text,
    formatted_name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    subfolder character varying,
    year character varying,
    format_name character varying,
    source character varying,
    srrdb_last_verified_at timestamp without time zone,
    folder_created_at timestamp without time zone,
    folder_updated_at timestamp without time zone,
    data_url character varying
);


--
-- Name: releases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE releases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE releases_id_seq OWNED BY releases.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sfv_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sfv_files (
    id integer NOT NULL,
    release_id integer NOT NULL,
    file_uid character varying NOT NULL,
    file_name character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    source character varying
);


--
-- Name: sfv_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sfv_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sfv_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sfv_files_id_seq OWNED BY sfv_files.id;


--
-- Name: tracks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tracks (
    id integer NOT NULL,
    release_id integer NOT NULL,
    name character varying NOT NULL,
    format_info character varying NOT NULL,
    artist character varying,
    title character varying,
    album character varying,
    genre character varying,
    year character varying,
    bitrate integer,
    channels integer,
    length integer,
    sample_rate integer,
    format_name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    file_uid character varying,
    file_name character varying,
    process_id character varying,
    number character varying,
    deleted_at timestamp without time zone
);


--
-- Name: tracks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tracks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tracks_id_seq OWNED BY tracks.id;


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE uploads (
    id integer NOT NULL,
    file_uid character varying NOT NULL,
    file_name character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone,
    object_changes text
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('friendly_id_slugs_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY images ALTER COLUMN id SET DEFAULT nextval('images_id_seq'::regclass);


--
-- Name: m3u_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY m3u_files ALTER COLUMN id SET DEFAULT nextval('m3u_files_id_seq'::regclass);


--
-- Name: releases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY releases ALTER COLUMN id SET DEFAULT nextval('releases_id_seq'::regclass);


--
-- Name: sfv_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sfv_files ALTER COLUMN id SET DEFAULT nextval('sfv_files_id_seq'::regclass);


--
-- Name: tracks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tracks ALTER COLUMN id SET DEFAULT nextval('tracks_id_seq'::regclass);


--
-- Name: uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: m3u_files m3u_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY m3u_files
    ADD CONSTRAINT m3u_files_pkey PRIMARY KEY (id);


--
-- Name: releases releases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY releases
    ADD CONSTRAINT releases_pkey PRIMARY KEY (id);


--
-- Name: sfv_files sfv_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sfv_files
    ADD CONSTRAINT sfv_files_pkey PRIMARY KEY (id);


--
-- Name: tracks tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_images_on_release_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_images_on_release_id ON images USING btree (release_id);


--
-- Name: index_m3u_files_on_release_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m3u_files_on_release_id ON m3u_files USING btree (release_id);


--
-- Name: index_releases_on_data_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_releases_on_data_url ON releases USING btree (data_url);


--
-- Name: index_releases_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_releases_on_name ON releases USING btree (name);


--
-- Name: index_sfv_files_on_release_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sfv_files_on_release_id ON sfv_files USING btree (release_id);


--
-- Name: index_tracks_on_format_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tracks_on_format_name ON tracks USING btree (format_name);


--
-- Name: index_tracks_on_release_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tracks_on_release_id ON tracks USING btree (release_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20150326232536'),
('20150516233141'),
('20150822175748'),
('20150829150052'),
('20150906182151'),
('20150906201817'),
('20150913185133'),
('20150920123243'),
('20150924012943'),
('20150926131407'),
('20151004150048'),
('20151004160152'),
('20151004172324'),
('20151009015928'),
('20151010153614'),
('20151012032252'),
('20151012034225'),
('20151012034723'),
('20151031162241'),
('20151031171634'),
('20160521153356'),
('20160702110906'),
('20160702112654'),
('20160702131009'),
('20160702141851'),
('20160703082507'),
('20160705165152'),
('20160705175855'),
('20160714120711'),
('20160817092026'),
('20160823130616'),
('20160823171156'),
('20160823171719'),
('20161004135805'),
('20161011122633'),
('20171101075211'),
('20171111112943'),
('20171111115428'),
('20171118103631');


