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

static mrb_value
hs_regexp_initialize(mrb_state *mrb, mrb_value self)
{
    struct mrb_hs_regexp *reg;
    char *str;

    mrb_get_args(mrb, "z", &str);

    if (!DATA_PTR(self)){
        reg = DATA_PTR(self) = mrb_malloc(mrb, sizeof(mrb_hs_regexp_type));
        DATA_TYPE(self) = &mrb_hs_regexp_type;
    }else{
        Data_Get_Struct(mrb, self, &mrb_hs_regexp_type, reg);
        mrb_free(mrb, reg->reg);
    }

    reg->reg = regcomp(mrb, str);
    if (!reg->reg){
        mrb_raisef(mrb, E_ARGUMENT_ERROR, "'%s' is an invalid regular expression.", str);
    }
    mrb_iv_set(mrb, self, INTERN("@string"), mrb_str_new_cstr(mrb, str));

    return mrb_nil_value();
}

static mrb_value
hs_regexp_get_match_data(mrb_state *mrb, mrb_value self, const char *str)
{
    size_t i;
    mrb_value hs_match_data_cls, match_data, str_value;
    mrb_value args[2];
    mrb_sym sym_push;
    struct mrb_hs_regexp *reg;

    reg = DATA_PTR(self);

    hs_match_data_cls = mrb_const_get(mrb, mrb_obj_value(mrb->object_class), INTERN("HsMatchData"));
    match_data = mrb_funcall_argv(mrb, hs_match_data_cls, INTERN("new"), 0, NULL);
    sym_push = INTERN("push");

    args[0] = str_value = mrb_str_new(mrb, reg->reg->startp[0], reg->reg->endp[0] - reg->reg->startp[0]);
    args[1] = mrb_fixnum_value(reg->reg->startp[0] - str);
    mrb_funcall_argv(mrb, match_data, sym_push, sizeof(args)/sizeof(args[0]), &args[0]);
    for (i = 1; i < sizeof(reg->reg->startp)/sizeof(reg->reg->startp[0]); i++){
        if (reg->reg->startp[i] && reg->reg->endp[i]){
            args[0] = mrb_str_substr(mrb, str_value,
                                     (mrb_int)(reg->reg->startp[i] - reg->reg->startp[0]),
                                     reg->reg->endp[i] - reg->reg->startp[i]);
            args[1] = mrb_fixnum_value(reg->reg->startp[i] - str);
            mrb_funcall_argv(mrb, match_data, sym_push, sizeof(args)/sizeof(args[0]), &args[0]);
        }else{
            mrb_funcall_argv(mrb, match_data, sym_push, 0, NULL);
        }
    }

    return match_data;
}

static mrb_value
hs_regexp_match(mrb_state *mrb, mrb_value self)
{
    const char *str;
    struct mrb_hs_regexp *reg;

    mrb_get_args(mrb, "z", &str);

    Data_Get_Struct(mrb, self, &mrb_hs_regexp_type, reg);
    if (!reg->reg){
        mrb_raise(mrb, E_ARGUMENT_ERROR, "HsRegexp is not initialized.");
    }

    if (!regexec(reg->reg, str)){
        return mrb_nil_value();
    }

    return hs_regexp_get_match_data(mrb, self, str);
}

////////////////////////////////////////////////////////////////
void regerror(char *message)
{
}

////////////////////////////////////////////////////////////////
void
mrb_mruby_hs_regexp_gem_init(mrb_state* mrb)
{
    struct RClass *r;

    r = mrb_define_class(mrb, "HsRegexp", mrb->object_class);
    MRB_SET_INSTANCE_TT(r, MRB_TT_DATA);

    mrb_define_method(mrb, r, "initialize", hs_regexp_initialize, ARGS_REQ(1));
    mrb_define_method(mrb, r, "match", hs_regexp_match, ARGS_REQ(1));
}

void
mrb_mruby_hs_regexp_gem_final(mrb_state* mrb)
{
}
