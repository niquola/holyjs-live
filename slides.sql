--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: plv8; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plv8 WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plv8; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plv8 IS 'PL/JavaScript (v8) trusted procedural language';


--
-- Name: jsquery; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS jsquery WITH SCHEMA public;


--
-- Name: EXTENSION jsquery; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION jsquery IS 'data type for jsonb inspection';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = public, pg_catalog;

--
-- Name: rec; Type: TYPE; Schema: public; Owner: nicola
--

CREATE TYPE rec AS (
	i integer,
	t text
);


ALTER TYPE rec OWNER TO nicola;

--
-- Name: add_slide(json); Type: FUNCTION; Schema: public; Owner: nicola
--

CREATE FUNCTION add_slide(obj json) RETURNS json
    LANGUAGE plv8
    AS $$
  var mod = require("/home/nicola/holyjs/db/index.js")
  return mod.add_slide(plv8, obj)
$$;


ALTER FUNCTION public.add_slide(obj json) OWNER TO nicola;

--
-- Name: down_slide(json); Type: FUNCTION; Schema: public; Owner: nicola
--

CREATE FUNCTION down_slide(obj json) RETURNS json
    LANGUAGE plv8
    AS $$
  var mod = require("/home/nicola/holyjs/db/index.js")
  return mod.down_slide(plv8, obj)
$$;


ALTER FUNCTION public.down_slide(obj json) OWNER TO nicola;

--
-- Name: myexec(); Type: FUNCTION; Schema: public; Owner: nicola
--

CREATE FUNCTION myexec() RETURNS json
    LANGUAGE plv8
    AS $$
  return plv8.execute('SELECT count(*) FROM slides')
$$;


ALTER FUNCTION public.myexec() OWNER TO nicola;

--
-- Name: myfn(json); Type: FUNCTION; Schema: public; Owner: nicola
--

CREATE FUNCTION myfn(obj json) RETURNS json
    LANGUAGE plv8
    AS $$
  var mod = require("/home/nicola/holyjs/db/index.js")
  return mod.myfn(plv8, obj)
$$;


ALTER FUNCTION public.myfn(obj json) OWNER TO nicola;

--
-- Name: plv8_init(); Type: FUNCTION; Schema: public; Owner: nicola
--

CREATE FUNCTION plv8_init() RETURNS text
    LANGUAGE plv8 IMMUTABLE STRICT
    AS $_$
  var _modules = {};
  var _current_stack = [];

  // modules start
  _modules["/home/nicola/holyjs/db/index.js"] = {
  init:  function(){
    var exports = {};
    _current_stack.push({ file: "index.js", dir: "/home/nicola/holyjs/db"})
    var module = { exports: exports};
    exports.add_slide = function(plv8, obj){
  res = plv8.execute(
    'INSERT INTO slides ' +
    '(title, code, position) values '+
    '($1, $2, (SELECT max(position) + 1 FROM slides LIMIT 1))'+
    ' RETURNING *',
    [obj.title, obj.code]
  );
  return JSON.stringify(res[0]);
};
exports.add_slide.plv8_signature = ['json','json'];

exports.update_slide = function(plv8, obj){
    plv8.execute('UPDATE slides SET title = $2, code = $3 WHERE id = $1', [obj.id, obj.title, obj.code]);
    return obj;
};
exports.update_slide.plv8_signature = ['json','json'];

exports.rm_slide = function(plv8, obj){
    plv8.execute('DELETE FROM slides where id = $1', [obj.id]);
    return obj;
};
exports.rm_slide.plv8_signature = ['json','json'];

exports.up_slide = function(plv8, obj){
    plv8.execute('UPDATE slides  SET position = position+1 where position = $1', [obj.position - 1]);
    plv8.execute('UPDATE slides  SET position = position-1 where id = $1', [obj.id]);
    return obj;
};
exports.up_slide.plv8_signature = ['json','json'];

exports.down_slide = function(plv8, obj){
    plv8.execute('UPDATE slides  SET position = position-1 where position = $1', [obj.position + 1]);
    plv8.execute('UPDATE slides  SET position = position+1 where id = $1', [obj.id]);
    return obj;
};
exports.down_slide.plv8_signature = ['json','json'];


exports.myfn = function(plv8, obj){
    return {"hello": "HolyJS"}
};
exports.myfn.plv8_signature = ['json','json'];

    _current_stack.pop()
    return module.exports;
  }
}
  // modules stop

  this.require = function(dep){
    var abs_path = dep.replace(/\.(coffee|litcoffee)$/, '');
    var current = _current_stack[_current_stack.length - 1];
    if(dep.match(/^\.\.\/\.\.\//)){
      var dir = current.dir.split('/');
      dir.pop();
      dir.pop();
      abs_path = dir.join('/') + '/' + dep.replace('../../','');
    } else if(dep.match(/^\.\.\//)) {
      var dir = current.dir.split('/');
      dir.pop();
      abs_path = dir.join('/') + '/' + dep.replace('../','');
    } else if(dep.match(/^\.\//)) {
      abs_path = current.dir + '/' + dep.replace('./','');
    }
    // todo resolve paths
    var mod = _modules[abs_path]
    if(!mod){ throw new Error("No module " + abs_path + " while loading " + JSON.stringify(_current_stack)); }
    if(!mod.cached){
      if(mod.inprogress){ throw new Error("Cyclic dependecy " + abs_path) }
      mod.inprogress = true
      mod.cached = mod.init()
      mod.inprogress = false
    }
    return mod.cached
  }
  this.modules = function(){
    var res = []
    for(var k in _modules){ res.push(k) }
    return res;
  }
  this.console = {
    log: function(x){ plv8.elog(NOTICE, x); }
  };

  plv8.cache = {}
  return 'done'
$_$;


ALTER FUNCTION public.plv8_init() OWNER TO nicola;

--
-- Name: rm_slide(json); Type: FUNCTION; Schema: public; Owner: nicola
--

CREATE FUNCTION rm_slide(obj json) RETURNS json
    LANGUAGE plv8
    AS $$
  var mod = require("/home/nicola/holyjs/db/index.js")
  return mod.rm_slide(plv8, obj)
$$;


ALTER FUNCTION public.rm_slide(obj json) OWNER TO nicola;

--
-- Name: set_of_records(); Type: FUNCTION; Schema: public; Owner: nicola
--

CREATE FUNCTION set_of_records() RETURNS SETOF rec
    LANGUAGE plv8
    AS $$
    plv8.return_next( { "i": 1, "t": "a" } );
    plv8.return_next( { "i": 2, "t": "b" } );
    return [ { "i": 3, "t": "c" }, { "i": 4, "t": "d" } ];
$$;


ALTER FUNCTION public.set_of_records() OWNER TO nicola;

--
-- Name: testfn(json); Type: FUNCTION; Schema: public; Owner: nicola
--

CREATE FUNCTION testfn(inp json) RETURNS json
    LANGUAGE plv8 IMMUTABLE STRICT
    AS $$
   inp.touched = true;
   return inp;
$$;


ALTER FUNCTION public.testfn(inp json) OWNER TO nicola;

--
-- Name: up_slide(json); Type: FUNCTION; Schema: public; Owner: nicola
--

CREATE FUNCTION up_slide(obj json) RETURNS json
    LANGUAGE plv8
    AS $$
  var mod = require("/home/nicola/holyjs/db/index.js")
  return mod.up_slide(plv8, obj)
$$;


ALTER FUNCTION public.up_slide(obj json) OWNER TO nicola;

--
-- Name: update_slide(json); Type: FUNCTION; Schema: public; Owner: nicola
--

CREATE FUNCTION update_slide(obj json) RETURNS json
    LANGUAGE plv8
    AS $$
  var mod = require("/home/nicola/holyjs/db/index.js")
  return mod.update_slide(plv8, obj)
$$;


ALTER FUNCTION public.update_slide(obj json) OWNER TO nicola;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: _migrations; Type: TABLE; Schema: public; Owner: nicola; Tablespace: 
--

CREATE TABLE _migrations (
    name text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE _migrations OWNER TO nicola;

--
-- Name: mydata; Type: TABLE; Schema: public; Owner: nicola; Tablespace: 
--

CREATE TABLE mydata (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    content jsonb
);


ALTER TABLE mydata OWNER TO nicola;

--
-- Name: slides; Type: TABLE; Schema: public; Owner: nicola; Tablespace: 
--

CREATE TABLE slides (
    id integer NOT NULL,
    title text,
    code text,
    "position" integer
);


ALTER TABLE slides OWNER TO nicola;

--
-- Name: slides_id_seq; Type: SEQUENCE; Schema: public; Owner: nicola
--

CREATE SEQUENCE slides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE slides_id_seq OWNER TO nicola;

--
-- Name: slides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nicola
--

ALTER SEQUENCE slides_id_seq OWNED BY slides.id;


--
-- Name: test; Type: TABLE; Schema: public; Owner: nicola; Tablespace: 
--

CREATE TABLE test (
    id integer NOT NULL,
    label text
);


ALTER TABLE test OWNER TO nicola;

--
-- Name: test_id_seq; Type: SEQUENCE; Schema: public; Owner: nicola
--

CREATE SEQUENCE test_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE test_id_seq OWNER TO nicola;

--
-- Name: test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nicola
--

ALTER SEQUENCE test_id_seq OWNED BY test.id;


--
-- Name: todo; Type: TABLE; Schema: public; Owner: nicola; Tablespace: 
--

CREATE TABLE todo (
    id integer NOT NULL,
    content jsonb
);


ALTER TABLE todo OWNER TO nicola;

--
-- Name: todo_id_seq; Type: SEQUENCE; Schema: public; Owner: nicola
--

CREATE SEQUENCE todo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE todo_id_seq OWNER TO nicola;

--
-- Name: todo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nicola
--

ALTER SEQUENCE todo_id_seq OWNED BY todo.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nicola
--

ALTER TABLE ONLY slides ALTER COLUMN id SET DEFAULT nextval('slides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nicola
--

ALTER TABLE ONLY test ALTER COLUMN id SET DEFAULT nextval('test_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nicola
--

ALTER TABLE ONLY todo ALTER COLUMN id SET DEFAULT nextval('todo_id_seq'::regclass);


--
-- Data for Name: _migrations; Type: TABLE DATA; Schema: public; Owner: nicola
--

COPY _migrations (name, created_at) FROM stdin;
2016_06_04T17_28_27_786Z__slides.coffee	2016-06-04 21:53:28.256166
2016_06_04T20_53_26_797Z__slides_position.coffee	2016-06-04 23:55:35.821164
\.


--
-- Data for Name: mydata; Type: TABLE DATA; Schema: public; Owner: nicola
--

COPY mydata (id, content) FROM stdin;
\.


--
-- Data for Name: slides; Type: TABLE DATA; Schema: public; Owner: nicola
--

COPY slides (id, title, code, "position") FROM stdin;
32	Another Search	SELECT count(*)\n    FROM mydata\n    WHERE content->>'title' ilike 'item-99%'	13
41	Extensions	SELECT * FROM pg_available_extensions	22
81	JSON to Rel	select * from \n  json_to_recordset(\n    '[{"a":1,"b":"foo"},{"a":"2","c":"bar"}]'\n  ) as x(a int, b text);	21
26	Access to jsonb	SELECT content->>'title' as title, \n            content#>>'{tags,0}' as tag1\n    FROM mydata\nLIMIT 10	8
29	Search Data	SELECT content->>'title' as title, \n            content#>>'{tags,0}' as tag1\n    FROM mydata\n    WHERE content->>'title' ilike '%js%'\nLIMIT 10	9
25	Add Data	INSERT into mydata (content) values\n('{"title":"holyjs", "tags":["js","pg"]}'),\n('{"title":"fprog", "tags":["clj","fp"]}')\nRETURNING *	7
31	Count Data	SELECT count(*) FROM mydata	12
28	Index	SELECT 'PostgreSQL is most advanced open source DB'	0
21	Types	SELECT typname \n   FROM pg_type \nWHERE typname not ilike '\\_%' \n    AND typname not ilike 'pg%'\nORDER BY typname	1
22	Dates & Times	select \n   '1980-03-05'::timestamp,\n   now() as now,\n   age('1980-03-05T10:00+03'::timestamptz)	2
18	Arrays	select \n  '{1,2,3}'::int[] as int_array,\n  ARRAY[1,4,3] @> ARRAY[3,1] as contains,\n  ARRAY[1,4,3] && ARRAY[2,1] as overlap	3
23	Ranges	select \n   '(2016-01-01,2016-02-01]'::tstzrange,\n   '[1,10)'::numrange,\n   numrange(5,15) + numrange(10,20) as sum	4
20	Jsonb	SELECT $JSON$\n   {\n      "name": "niquola", \n      "interests": ["clj", "pg", "Health IT"]\n   }\n   $JSON$::jsonb	5
27	Clear Data	DELETE FROM mydata	10
34	Index JSON	CREATE index name_idx\n    ON mydata USING gin ((content->>'title') gin_trgm_ops)	15
36	Drop Index	DROP INDEX name_idx	17
30	More Data	INSERT into mydata (content) \nSELECT \n(format('{"title":"item-%s", "tags":["tag-%s"]}', x, x))::jsonb FROM generate_series(0,100000) x	11
37	Explain Search	EXPLAIN SELECT count(*)\n    FROM mydata\n    WHERE content->>'title' ilike 'item-99%'	18
35	Search Again	SELECT count(*)\n    FROM mydata\n    WHERE content->>'title' ilike 'item-99%'	16
40	ROW_TO_JSON	SELECT row_to_json(x.*) from slides x\nwhere title ilike '%data%'	20
24	Prepare table	DROP table mydata;\nCREATE EXTENSION IF NOT EXISTS pgcrypto ;\nCREATE table mydata( \n  id uuid primary key default gen_random_uuid(), \n  content jsonb\n)	6
33	Add Extension trgm	CREATE EXTENSION IF NOT EXISTS pg_trgm	14
39	JSON_AGG	SELECT json_build_object(\n    'slides', (SELECT json_agg(s.*) FROM \n                    (SELECT * FROM slides s LIMIT 2) s),\n    'count', (SELECT count(*) FROM slides),\n    'mydata_count', (SELECT count(*) FROM mydata)\n  )	19
46	plv8: execute	CREATE OR REPLACE\nFUNCTION myexec() RETURNS json AS $$\n  return plv8.execute('SELECT count(*) FROM slides')\n$$ LANGUAGE plv8;\n\nSELECT * FROM myexec()	27
45	plv8: returning	-- CREATE TYPE rec AS (i integer, t text);\nCREATE OR REPLACE\nFUNCTION set_of_records() RETURNS SETOF rec AS $$\n    plv8.return_next( { "i": 1, "t": "a" } );\n    plv8.return_next( { "i": 2, "t": "b" } );\n    return [ { "i": 3, "t": "c" }, { "i": 4, "t": "d" } ];\n$$ LANGUAGE plv8;\n\nSELECT * FROM set_of_records()	26
43	JS function	CREATE OR REPLACE \nFUNCTION testfn(inp json) RETURNS json AS $$\n   inp.touched = true;\n   return inp;\n$$ LANGUAGE plv8 IMMUTABLE STRICT;\n\nSELECT testfn('{}');	25
42	Languages	select * from pg_language	24
44	JSQUERY	-- create extension jsquery;\nselect\n  '{"a": {"b": 1}}'::jsonb @@ 'a.b = 1' as exp1,\n  '[{"a": 2}, {"a": 3}, {"a": {"a":4}}]'::jsonb @@ '#(a = 1 OR a=3)' as exp2,\n  '{"a": {"b": [1,2,3]}}'::jsonb @@ '*.b && [ 1 ]' as "exp3"	23
\.


--
-- Name: slides_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nicola
--

SELECT pg_catalog.setval('slides_id_seq', 81, true);


--
-- Data for Name: test; Type: TABLE DATA; Schema: public; Owner: nicola
--

COPY test (id, label) FROM stdin;
1	row-0
2	row-1
3	row-2
4	row-3
5	row-4
6	row-5
7	row-6
8	row-7
9	row-8
10	row-9
11	row-10
12	row-11
13	row-12
14	row-13
15	row-14
16	row-15
17	row-16
18	row-17
19	row-18
20	row-19
21	row-20
22	row-21
23	row-22
24	row-23
25	row-24
26	row-25
27	row-26
28	row-27
29	row-28
30	row-29
31	row-30
32	row-31
33	row-32
34	row-33
35	row-34
36	row-35
37	row-36
38	row-37
39	row-38
40	row-39
41	row-40
42	row-41
43	row-42
44	row-43
45	row-44
46	row-45
47	row-46
48	row-47
49	row-48
50	row-49
51	row-50
52	row-51
53	row-52
54	row-53
55	row-54
56	row-55
57	row-56
58	row-57
59	row-58
60	row-59
61	row-60
62	row-61
63	row-62
64	row-63
65	row-64
66	row-65
67	row-66
68	row-67
69	row-68
70	row-69
71	row-70
72	row-71
73	row-72
74	row-73
75	row-74
76	row-75
77	row-76
78	row-77
79	row-78
80	row-79
81	row-80
82	row-81
83	row-82
84	row-83
85	row-84
86	row-85
87	row-86
88	row-87
89	row-88
90	row-89
91	row-90
92	row-91
93	row-92
94	row-93
95	row-94
96	row-95
97	row-96
98	row-97
99	row-98
100	row-99
101	row-100
\.


--
-- Name: test_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nicola
--

SELECT pg_catalog.setval('test_id_seq', 101, true);


--
-- Data for Name: todo; Type: TABLE DATA; Schema: public; Owner: nicola
--

COPY todo (id, content) FROM stdin;
1	{"text": "Hello"}
\.


--
-- Name: todo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nicola
--

SELECT pg_catalog.setval('todo_id_seq', 1, true);


--
-- Name: _migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: nicola; Tablespace: 
--

ALTER TABLE ONLY _migrations
    ADD CONSTRAINT _migrations_pkey PRIMARY KEY (name);


--
-- Name: mydata_pkey; Type: CONSTRAINT; Schema: public; Owner: nicola; Tablespace: 
--

ALTER TABLE ONLY mydata
    ADD CONSTRAINT mydata_pkey PRIMARY KEY (id);


--
-- Name: name_idx; Type: INDEX; Schema: public; Owner: nicola; Tablespace: 
--

CREATE INDEX name_idx ON mydata USING gin (((content ->> 'title'::text)) gin_trgm_ops);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

