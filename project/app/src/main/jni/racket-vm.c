Scheme_Object *_scheme_make_stdio(const char *label) {
    Scheme_Object *v = NULL;

    v = scheme_intern_symbol(label);
    v = scheme_make_output_port(
            v,
            NULL,
            v,
            NULL,
            _stdio_writes_bytes,
            _stdio_char_ready,
            _stdio_close,
            _stdio_need_wakeup,
            NULL,
            NULL,
            0 );

    return v;
}

static int vm_init(void *d)
{
	Scheme_Env *e = NULL;
	Scheme_Object *a[2];
	Scheme_Object *mp = NULL, *ra = NULL, *v = NULL, *vec = NULL;

	e = scheme_basic_env();

	declare_modules(e);

	v = scheme_make_null();
	mp = scheme_intern_symbol("app");
	mp = scheme_make_pair(mp, v);
	v = scheme_intern_symbol("quote");
	mp = scheme_make_pair(v, mp);
	a[0] = mp;
  	a[1] = scheme_false;
  	scheme_dynamic_require(2, a);
  	return 0;
}
