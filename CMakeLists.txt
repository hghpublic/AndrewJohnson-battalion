cmake_minimum_required(VERSION 4.1)

project(battalion
    VERSION 1.4.0
    DESCRIPTION "Monsters, explosions, senseless destruction. You've seen the \
movies, you know what to do."
    HOMEPAGE_URL https://www.evl.uic.edu/aej/AndyBattalion.html
    LANGUAGES C
)

option(BUILD_WITH_SANITIZERS "Build with sanitizers" ON)

find_package(X11 REQUIRED)
find_package(OpenGL REQUIRED)

set(target ${PROJECT_NAME})
add_executable(${target})
target_compile_features(${target} PRIVATE c_std_23)
target_compile_definitions(${target} PRIVATE LINUXAUDIO)
target_sources(${target} PRIVATE
    battalion.c
    battalion.h
   
    audio.c
    font.c
    gprim.c
    graphics.c
    net.c
    objects.c
    soundIt.c
    soundIt.h
    text.c
    tk.c
    tk.h
    update.c
)
target_link_libraries(${target} PRIVATE OpenGL::GL OpenGL::GLU)
target_link_libraries(${target} PRIVATE X11::X11)
target_link_libraries(${target} PRIVATE m)
if(BUILD_WITH_SANITIZERS)
    target_compile_options(${target} PRIVATE -fsanitize=address)
    target_link_options(${target} PRIVATE -fsanitize=address)
    
    # Set ASAN suppression file environment variable
    set(ASAN_SUPPRESSION_FILE "${CMAKE_SOURCE_DIR}/asan.supp")
    set_target_properties(${target} PROPERTIES
        VS_DEBUGGER_ENVIRONMENT "LSAN_OPTIONS=suppressions=${ASAN_SUPPRESSION_FILE}:print_suppressions=1"
    )
endif()

# copy assets and create empty hiscore and battalion.sho files

set(asset_dirs
    DATA
    MUSIC
    SOUNDS
    TEXTURES
)
foreach(dir ${asset_dirs})
add_custom_command(TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/${dir} $<TARGET_FILE_DIR:${target}>/battalion.data/${dir})    
endforeach()
add_custom_command(TARGET ${target} POST_BUILD COMMAND touch $<TARGET_FILE_DIR:${target}>/battalion.data/battalion.sho)
add_custom_command(TARGET ${target} POST_BUILD COMMAND touch $<TARGET_FILE_DIR:${target}>/battalion_hiscore)
