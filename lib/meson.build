project('beryl', 'c',
  version : '0.1',
  default_options : ['warning_level=3'])

if meson.get_compiler('c').get_id() == 'msvc'
  add_project_arguments('-DNO_TIMER', language : 'c')
endif

if meson.get_compiler('c').get_id() == 'clang'
  add_project_arguments('-fdeclspec', '-fPIC', language : 'c')
  add_project_link_arguments('-shared', language : 'c')
endif

if host_machine.cpu_family() == 'x86'
  add_project_arguments('-DCPU86', language : 'c')
endif

library('beryl',
           'beryl/api.c',
           'beryl/linked_list.c',
           'beryl/navmesh_generate.c',
           'beryl/navmesh_query.c',
           'beryl/vector_math.c',
           'beryl/vector_math.c',
           'external/triangle/triangle.c',
           'external/gpc/gpc.c',
           c_args : ['-DANSI_DECLARATORS', '-DTRILIBRARY'],
        )
