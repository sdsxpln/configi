MAKEFLAGS= --silent
TESTLOG_F = test.log
AUX_P = aux
LUAC_T= bin/luac
LUAC2C_T= bin/luac2c
SOLDFLAGS= $(LDFLAGS) $(VLUA_O)
LUA_O= liblua.o
LUA_T= bin/lua
ONE= $(AUX_P)/one
SRLUA= $(AUX_P)/srlua
SRLUA_T = bin/srlua
GLUE_SRC= $(AUX_P)/glue
GLUE_T= bin/glue
CFG= bin/cfg.lua
CFG_T= bin/cfg

LUACFLAGS= -s
ECHO = printf '%s\n'
ECHON = printf '%s'
ECHOT = printf ' %s\t%s\n'
RM= rm
RMDIR= rmdir
RMFLAGS= -f
SED= sed
SEDFLAGS= -i
UPX= upx
UPXFLAGS= --best --ultra-brute
STRIPFLAGS= --strip-all
LN= ln
LNFLAGS= -sf
INSTALL= install
INSTALLFLAGS= -b
MV= mv
UNLINK= unlink
CHMOD= chmod

_rest= $(wordlist 2,$(words $(1)),$(1))
_lget= $(firstword lib/$(1))/Makefile $(if $(_rest),$(call _lget,$(_rest)),)
_vget= $(firstword vendor/$(1))/Makefile $(if $(_rest),$(call _vget,$(_rest)),)
SRC_P= vendor/lua
INCLUDES:= -I$(SRC_P) -Iinclude -I$(AUX_P)
LINIT_T:= $(SRC_P)/linit.c
LDLIBS+= $(foreach m, $(LIB), -Llib/$m -l$m)
LDLIBS+= $(foreach m, $(VENDOR), -Lvendor/$m -l$m)
LDLIBS+= $(foreach m, $(MODULES), -Lmodules -l$m)
LDEFINES+= $(foreach d, $(LIB) $(VENDOR), -Dlib_$d)
LDEFINES+= $(foreach d, $(MODULES), -Dmodule_$d)
DEPS+= $(foreach d, $(MODULES), modules/lib$d.a)
