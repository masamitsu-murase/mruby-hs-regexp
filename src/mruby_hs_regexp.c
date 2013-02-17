#include <stdio.h>
#include <mruby.h>
#include <mruby/class.h>
#include <mruby/variable.h>
#include <mruby/string.h>
#include <mruby/data.h>
#include "regexp.h"

#define INTERN(str) mrb_intern2(mrb, str, sizeof(str) - 1)

////////////////////////////////////////////////////////////////
struct mrb_hs_regexp
{
    regexp *reg;
    unsigned char flag;
};

static void
hs_regexp_free(mrb_state *mrb, void *ptr)
{
    if (ptr){
        struct mrb_hs_regexp *p = (struct mrb_hs_regexp *)ptr;
        mrb_free(mrb, p->reg);
        p->reg = NULL;
    }
    mrb_free(mrb, ptr);
}

static struct mrb_data_type mrb_hs_regexp_type = { "HsRegexp", hs_regexp_free };

static void
hs_regexp_init(mrb_state *mrb, mrb_value self, mrb_value str, unsigned char flag)
{
    struct mrb_hs_regexp *reg;
    regexp_info ri = { mrb, flag };

    if (flag & ~REGEXP_FLAG_ALL){
        mrb_raise(mrb, E_ARGUMENT_ERROR, "Invalid flag.");
    }

    if (!DATA_PTR(self)){
        DATA_PTR(self) = mrb_malloc(mrb, sizeof(struct mrb_hs_regexp));
        DATA_TYPE(self) = &mrb_hs_regexp_type;
        reg = (struct mrb_hs_regexp *)DATA_PTR(self);
    }else{
        Data_Get_Struct(mrb, self, &mrb_hs_regexp_type, reg);
        mrb_free(mrb, reg->reg);
    }

    reg->reg = regcomp(&ri, RSTRING_PTR(str));
    if (!reg->reg){
        mrb_raisef(mrb, E_ARGUMENT_ERROR, "'%s' is an invalid regular expression because %s.",
                   RSTRING_PTR(str), ri.error_msg);
    }
    reg->flag = flag;
    mrb_iv_set(mrb, self, INTERN("@source"), str);
}

static mrb_value
hs_regexp_initialize(mrb_state *mrb, mrb_value self)
{
    char *str;
    int len;
    mrb_value source;
    mrb_int flag = 0;

    mrb_get_args(mrb, "s|i", &str, &len, &flag);

    source = mrb_str_new(mrb, str, len);
    hs_regexp_init(mrb, self, source, (unsigned char)flag);

    return mrb_nil_value();
}

static mrb_value
hs_regexp_initialize_copy(mrb_state *mrb, mrb_value copy)
{
    mrb_value src;
    struct mrb_hs_regexp *reg;

    mrb_get_args(mrb, "o", &src);
    if (mrb_obj_equal(mrb, copy, src)){
        return copy;
    }
    if (!mrb_obj_is_instance_of(mrb, src, mrb_obj_class(mrb, copy))){
        mrb_raise(mrb, E_TYPE_ERROR, "wrong argument class");
    }

    Data_Get_Struct(mrb, src, &mrb_hs_regexp_type, reg);
    hs_regexp_init(mrb, copy, mrb_funcall_argv(mrb, src, INTERN("source"), 0, NULL), reg->flag);
    return copy;
}

static mrb_value
hs_regexp_get_match_data(mrb_state *mrb, mrb_value self, const char *str)
{
    mrb_value hs_match_data_cls, match_data;
    struct mrb_hs_regexp *reg;

    reg = DATA_PTR(self);

    hs_match_data_cls = mrb_const_get(mrb, mrb_obj_value(mrb->object_class), INTERN("HsMatchData"));
    match_data = mrb_funcall_argv(mrb, hs_match_data_cls, INTERN("new"), 0, NULL);

    mrb_iv_set(mrb, match_data, INTERN("@string"), mrb_str_new_cstr(mrb, str));

    {
        mrb_value args[2];
        mrb_sym sym_push;
        size_t i;

        sym_push = INTERN("push");
        for (i = 0; i < sizeof(reg->reg->startp)/sizeof(reg->reg->startp[0]); i++){
            if (reg->reg->startp[i] && reg->reg->endp[i]){
                args[0] = mrb_fixnum_value(reg->reg->startp[i] - str);
                args[1] = mrb_fixnum_value(reg->reg->endp[i] - reg->reg->startp[i]);
                mrb_funcall_argv(mrb, match_data, sym_push, sizeof(args)/sizeof(args[0]), &args[0]);
            }else{
                mrb_funcall_argv(mrb, match_data, sym_push, 0, NULL);
            }
        }
    }

    return match_data;
}

static mrb_value
hs_regexp_match(mrb_state *mrb, mrb_value self)
{
    const char *str;
    struct mrb_hs_regexp *reg;
    mrb_value m;
    regexp_info ri = { mrb };

    mrb_get_args(mrb, "z", &str);

    Data_Get_Struct(mrb, self, &mrb_hs_regexp_type, reg);
    if (!reg->reg){
        mrb_raise(mrb, E_ARGUMENT_ERROR, "HsRegexp is not initialized.");
    }

    ri.flag = reg->flag;
    if (regexec(&ri, reg->reg, str)){
        m = hs_regexp_get_match_data(mrb, self, str);
    }else{
        m = mrb_nil_value();
    }

    mrb_obj_iv_set(mrb, (struct RObject *)mrb_class_real(RDATA(self)->c), INTERN("@last_match"), m);
    return m;
}

////////////////////////////////////////////////////////////////
void regerror(regexp_info *ri, char *message)
{
    ri->error_msg = message;
}

////////////////////////////////////////////////////////////////
void
mrb_mruby_hs_regexp_gem_init(mrb_state* mrb)
{
    struct RClass *r;

    r = mrb_define_class(mrb, "HsRegexp", mrb->object_class);
    MRB_SET_INSTANCE_TT(r, MRB_TT_DATA);

    mrb_define_const(mrb, r, "IGNORECASE", mrb_fixnum_value(REGEXP_FLAG_IGNORECASE));
    mrb_define_const(mrb, r, "MULTILINE", mrb_fixnum_value(REGEXP_FLAG_MULTILINE));

    mrb_define_method(mrb, r, "initialize", hs_regexp_initialize, ARGS_ANY());
    mrb_define_method(mrb, r, "initialize_copy", hs_regexp_initialize_copy, ARGS_REQ(1));
    mrb_define_method(mrb, r, "match", hs_regexp_match, ARGS_REQ(1));
}

void
mrb_mruby_hs_regexp_gem_final(mrb_state* mrb)
{
}
