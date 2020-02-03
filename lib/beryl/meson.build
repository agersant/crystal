project('beryl', 'c',
  version : '0.1',
  default_options : ['warning_level=3'])

if meson.get_compiler('c').get_id() == 'msvc'
  add_global_arguments('-DNO_TIMER', language : 'c')
endif

library('beryl',
           'src/api.c',
           'src/linked_list.c',
           'src/navmesh_generate.c',
           'src/navmesh_query.c',
           'src/vector_math.c',
           'src/vector_math.c',
           'external/gpc/gpc.c',
           'external/triangle/triangle.c',
           c_args : ['-DANSI_DECLARATORS', '-DTRILIBRARY', '-DCPU86']
        )
