include (ValaPrecompile)
vala_precompile (VALA_C
    config.vala
    Application.vala
    MainWindow.vala
    Backend/CalcManager.vala
PACKAGES
    gtk+-3.0
    gio-2.0
    posix
    ticables2
    tifiles2
    ticalcs2
OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/vapi/
    --thread
    --target-glib=2.32
)

add_definitions (-w)

add_executable (${CMAKE_PROJECT_NAME} ${VALA_C})

install (TARGETS ${CMAKE_PROJECT_NAME} RUNTIME DESTINATION bin)