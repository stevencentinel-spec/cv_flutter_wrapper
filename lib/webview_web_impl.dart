// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Map<String, html.IFrameElement> _iframes = {};

void registerWebIframe(String htmlContent, String viewId) {
  final iframe = html.IFrameElement()
    ..style.border = 'none'
    ..style.width = '100%'
    ..style.height = '100%'
    ..srcdoc = htmlContent;

  _iframes[viewId] = iframe;

  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
        (int id) => _iframes[viewId]!,
  );
}

void executeJsInWebIframe(String jsCode, String viewId) {
  final iframe = _iframes[viewId];
  if (iframe != null) {
    iframe.contentWindow?.postMessage(jsCode, '*');
  }
}

Widget buildWebIframe(String viewId) {
  return HtmlElementView(viewType: viewId);
}