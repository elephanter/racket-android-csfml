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

