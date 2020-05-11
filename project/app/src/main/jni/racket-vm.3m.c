#define GC_VARIABLE_STACK GC_variable_stack
#define GET_GC_VARIABLE_STACK() GC_VARIABLE_STACK
#define SET_GC_VARIABLE_STACK(v) (GC_VARIABLE_STACK = (v))
#define PREPARE_VAR_STACK(size) void *__gc_var_stack__[size+2]; __gc_var_stack__[0] = GET_GC_VARIABLE_STACK(); SET_GC_VARIABLE_STACK(__gc_var_stack__);
#define PREPARE_VAR_STACK_ONCE(size) PREPARE_VAR_STACK(size); __gc_var_stack__[1] = (void *)size;
#define SETUP(x) (__gc_var_stack__[1] = (void *)x)
#ifdef MZ_3M_CHECK_VAR_STACK
static int _bad_var_stack_() { *(long *)0x0 = 1; return 0; }
# define CHECK_GC_V_S ((GC_VARIABLE_STACK == __gc_var_stack__) ? 0 : _bad_var_stack_()),
#else
# define CHECK_GC_V_S /*empty*/
#endif
#define FUNCCALL_each(setup, x) (CHECK_GC_V_S setup, x)
#define FUNCCALL_EMPTY_each(x) (SET_GC_VARIABLE_STACK((void **)__gc_var_stack__[0]), x)
#define FUNCCALL_AGAIN_each(x) (CHECK_GC_V_S x)
#define FUNCCALL_once(setup, x) FUNCCALL_AGAIN_each(x)
#define FUNCCALL_EMPTY_once(x) FUNCCALL_EMPTY_each(x)
#define FUNCCALL_AGAIN_once(x) FUNCCALL_AGAIN_each(x)
#define PUSH(v, x) (__gc_var_stack__[x+2] = (void *)&(v))
#define PUSHARRAY(v, l, x) (__gc_var_stack__[x+2] = (void *)0, __gc_var_stack__[x+3] = (void *)&(v), __gc_var_stack__[x+4] = (void *)l)
#define BLOCK_SETUP_TOP(x) x
#define BLOCK_SETUP_each(x) BLOCK_SETUP_TOP(x)
#define BLOCK_SETUP_once(x) /* no effect */
#define RET_VALUE_START return (__ret__val__ = 
#define RET_VALUE_END , SET_GC_VARIABLE_STACK((void **)__gc_var_stack__[0]), __ret__val__)
#define RET_VALUE_EMPTY_START return
#define RET_VALUE_EMPTY_END 
#define RET_NOTHING { SET_GC_VARIABLE_STACK((void **)__gc_var_stack__[0]); return; }
#define RET_NOTHING_AT_END { SET_GC_VARIABLE_STACK((void **)__gc_var_stack__[0]); }
#define DECL_RET_SAVE(type) type __ret__val__;
#define NULLED_OUT 0
#define NULL_OUT_ARRAY(a) memset(a, 0, sizeof(a))
#define GC_CAN_IGNORE /**/
#define XFORM_CAN_IGNORE /**/
#define __xform_nongcing__ /**/
#define __xform_nongcing_nonaliasing__ /**/
#define HIDE_FROM_XFORM(x) x
#define XFORM_HIDE_EXPR(x) x
#define HIDE_NOTHING_FROM_XFORM() /**/
#define START_XFORM_SKIP /**/
#define END_XFORM_SKIP /**/
#define START_XFORM_SUSPEND /**/
#define END_XFORM_SUSPEND /**/
#define XFORM_START_SKIP /**/
#define XFORM_END_SKIP /**/
#define XFORM_START_SUSPEND /**/
#define XFORM_END_SUSPEND /**/
#define XFORM_SKIP_PROC /**/
#define XFORM_ASSERT_NO_CONVERSION /**/
#define XFORM_OK_PLUS +
#define XFORM_OK_MINUS -
#define XFORM_TRUST_PLUS +
#define XFORM_TRUST_MINUS -
#define XFORM_OK_ASSIGN /**/

#define NEW_OBJ(t) new (UseGC) t
#define NEW_ARRAY(t, array) (new (UseGC) t array)
#define NEW_ATOM(t) (new (AtomicGC) t)
#define NEW_PTR(t) (new (UseGC) t)
#define NEW_ATOM_ARRAY(t, array) (new (AtomicGC) t array)
#define NEW_PTR_ARRAY(t, array) (new (UseGC) t* array)
#define DELETE(x) (delete x)
#define DELETE_ARRAY(x) (delete[] x)
#define XFORM_RESET_VAR_STACK /* empty */
#define scheme_mz_setjmp_post_xform(s) ((scheme_get_mz_setjmp())(s))

Scheme_Object * rap_scheme_make_stdio (const char * label ) {
  Scheme_Object * v = NULL ; 
  DECL_RET_SAVE (Scheme_Object * ) PREPARE_VAR_STACK_ONCE(1);
  BLOCK_SETUP_TOP((PUSH(v, 0)));
# define XfOrM1_COUNT (1)
# define SETUP_XfOrM1(x) SETUP(XfOrM1_COUNT)
# define BLOCK_SETUP(x) BLOCK_SETUP_once(x)
# define FUNCCALL(s, x) FUNCCALL_once(s, x)
# define FUNCCALL_EMPTY(x) FUNCCALL_EMPTY_once(x)
# define FUNCCALL_AGAIN(x) FUNCCALL_AGAIN_once(x)
  v = FUNCCALL(SETUP_XfOrM1(_), scheme_intern_symbol (label ) ); 
  v = FUNCCALL(SETUP_XfOrM1(_), scheme_make_output_port (v , NULL , v , NULL , rap_stdio_writes_bytes , rap_stdio_char_ready , rap_stdio_close , rap_stdio_need_wakeup , NULL , NULL , 0 ) ); 
  RET_VALUE_START (v ) RET_VALUE_END ; 
# undef BLOCK_SETUP
# undef FUNCCALL
# undef FUNCCALL_EMPTY
# undef FUNCCALL_AGAIN
}
static int rvm_init (void * d ) {
  Scheme_Env * e = NULL ; 
  Scheme_Object * a [3 ] = {
    NULL , NULL , NULL }
  ; 
  Scheme_Object * mp = NULL , * ra = NULL , * v = NULL , * vec = NULL ; 
  Scheme_Config * config = NULL ; 
  Scheme_Object * curout = NULL ; 
  DECL_RET_SAVE (int ) PREPARE_VAR_STACK_ONCE(10);
  BLOCK_SETUP_TOP((PUSH(v, 0), PUSH(mp, 1), PUSH(vec, 2), PUSH(e, 3), PUSH(curout, 4), PUSH(config, 5), PUSH(ra, 6), PUSHARRAY(a, 3, 7)));
# define XfOrM2_COUNT (10)
# define SETUP_XfOrM2(x) SETUP(XfOrM2_COUNT)
# define BLOCK_SETUP(x) BLOCK_SETUP_once(x)
# define FUNCCALL(s, x) FUNCCALL_once(s, x)
# define FUNCCALL_EMPTY(x) FUNCCALL_EMPTY_once(x)
# define FUNCCALL_AGAIN(x) FUNCCALL_AGAIN_once(x)
  a[0] = NULLED_OUT ; 
  a[1] = NULLED_OUT ; 
  a[2] = NULLED_OUT ; 
  e = FUNCCALL(SETUP_XfOrM2(_), scheme_basic_env () ); 
  config = FUNCCALL_AGAIN(scheme_current_config () ); 
  curout = FUNCCALL_AGAIN(scheme_get_param (config , MZCONFIG_OUTPUT_PORT ) ); 
  FUNCCALL_AGAIN(pipe (main_t_fd ) ); 
  FUNCCALL_AGAIN(ALOGE ("RC: Declaring modules..." ) ); 
  FUNCCALL_AGAIN(declare_modules (e ) ); 
  FUNCCALL_AGAIN(ALOGE ("RC: Done declaring modules..." ) ); 
  mp = FUNCCALL_AGAIN(scheme_make_null () ); 
  v = FUNCCALL_AGAIN(scheme_intern_symbol ("app" ) ); 
  mp = FUNCCALL_AGAIN(scheme_make_pair (v , mp ) ); 
  v = FUNCCALL_AGAIN(scheme_intern_symbol ("quote" ) ); 
  mp = FUNCCALL_AGAIN(scheme_make_pair (v , mp ) ); 
  FUNCCALL_AGAIN(ALOGE ("RC: Requiring modules..." ) ); 
  v = FUNCCALL_AGAIN(scheme_namespace_require (mp ) ); 
  FUNCCALL_AGAIN(ALOGE ("RC: Done requiring modules..." ) ); 
  a [0 ] = mp ; 
  a [1 ] = FUNCCALL(SETUP_XfOrM2(_), scheme_intern_symbol ("run-app" ) ); 
  a [2 ] = NULL ; 
  FUNCCALL(SETUP_XfOrM2(_), ALOGE ("RC: Resolving run-app" ) ); 
  ra = FUNCCALL_AGAIN(scheme_dynamic_require (2 , a ) ); 
  FUNCCALL_AGAIN(ALOGE ("RC: Done resolving run-app" ) ); 
  v = FUNCCALL_AGAIN(scheme_intern_symbol ("main-t-in" ) ); 
  a [0 ] = FUNCCALL(SETUP_XfOrM2(_), scheme_make_fd_input_port (main_t_fd [0 ] , v , 0 , 0 ) ); 
  a [1 ] = FUNCCALL(SETUP_XfOrM2(_), scheme_make_integer (sizeof (struct rvm_api_t ) ) ); 
  v = FUNCCALL(SETUP_XfOrM2(_), scheme_make_null () ); 
  vec = FUNCCALL_AGAIN(scheme_make_vector (5 , v ) ); 
  a [2 ] = vec ; 
  v = FUNCCALL(SETUP_XfOrM2(_), scheme_make_prim_w_arity (rap_audio , "RAPAudio.playSound" , 1 , 1 ) ); 
  FUNCCALL_AGAIN(SCHEME_VEC_ELS (vec ) )[0 ] = v ; 
  v = FUNCCALL(SETUP_XfOrM2(_), scheme_make_prim_w_arity (rap_set_label , "RAPSetLabel" , 1 , 1 ) ); 
  FUNCCALL_AGAIN(SCHEME_VEC_ELS (vec ) )[1 ] = v ; 
  v = FUNCCALL(SETUP_XfOrM2(_), scheme_make_prim_w_arity (rap_draw_frame_done , "RAPDrawFrameDone" , 0 , 0 ) ); 
  FUNCCALL_AGAIN(SCHEME_VEC_ELS (vec ) )[2 ] = v ; 
  v = FUNCCALL(SETUP_XfOrM2(_), scheme_make_prim_w_arity (rap_drive_read , "RAPDrive.read" , 1 , 1 ) ); 
  FUNCCALL_AGAIN(SCHEME_VEC_ELS (vec ) )[3 ] = v ; 
  v = FUNCCALL(SETUP_XfOrM2(_), scheme_make_prim_w_arity (rap_drive_write , "RAPDrive.write" , 2 , 2 ) ); 
  FUNCCALL_AGAIN(SCHEME_VEC_ELS (vec ) )[4 ] = v ; 
  FUNCCALL(SETUP_XfOrM2(_), ALOGE ("RC: Applying run-app" ) ); 
  v = FUNCCALL_AGAIN(scheme_apply (ra , 3 , a ) ); 
  FUNCCALL_AGAIN(ALOGE ("RC: Done applying run-app" ) ); 
  RET_VALUE_START (0 ) RET_VALUE_END ; 
# undef BLOCK_SETUP
# undef FUNCCALL
# undef FUNCCALL_EMPTY
# undef FUNCCALL_AGAIN
}
