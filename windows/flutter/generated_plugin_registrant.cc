//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_secure_storage_windows/flutter_secure_storage_windows_plugin.h>
#include <modal_progress_hud_nsn/modal_progress_hud_nsn_plugin.h>
#include <pasteboard/pasteboard_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterSecureStorageWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterSecureStorageWindowsPlugin"));
  ModalProgressHudNsnPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ModalProgressHudNsnPlugin"));
  PasteboardPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PasteboardPlugin"));
}
