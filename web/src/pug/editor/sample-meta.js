var sampleMeta = {
    "meta": {
        "margin": {
            "type": "number"
        },
        "font": {
            "family": {
                "type": "font"
            },
            "size": {
                "type": "quantity",
                "default": "1em",
                "units": [
                    {
                        "name": "em",
                        "max": 10,
                        "step": 0.01,
                        "default": 1
                    },
                    {
                        "name": "px",
                        "max": 256,
                        "step": 1,
                        "default": 16
                    }
                ]
            }
        },
        "color": {
            "type": "color",
            "default": "currentColor"
        },
        "palette": {
            "type": "palette"
        },
        "background": {
            "type": "color",
            "default": "transparent"
        },
        "legend": {
            "selectable": {
                "type": "boolean",
                "default": true
            },
            "enabled": {
                "type": "boolean",
                "default": true
            },
            "position": {
                "type": "choice",
                "values": [
                    "bottom",
                    "right"
                ],
                "default": "right"
            },
            "sort": {
                "direction": {
                    "type": "choice",
                    "values": [
                        "asc",
                        "desc"
                    ],
                    "default": "desc"
                },
                "mode": {
                    "type": "choice",
                    "values": [
                        "label",
                        "value",
                        "none"
                    ],
                    "default": "value"
                }
            }
        },
        "label": {
            "format": {
                "type": "format",
                "default": ".3s"
            }
        },
        "xaxis": {
            "enabled": {
                "type": "boolean",
                "default": true
            },
            "tick": {
                "inner": {
                    "type": "number",
                    "name": "Inner Tick Size",
                    "default": 8,
                    "min": 0,
                    "max": 40,
                    "step": 0.1
                },
                "color": {
                    "type": "color",
                    "default": "currentColor"
                },
                "count": {
                    "type": "number",
                    "default": 4,
                    "min": 1,
                    "max": 40
                },
                "boundaryOffset": {
                    "type": "boolean",
                    "default": true
                }
            },
            "baseline": {
                "show": {
                    "type": "boolean",
                    "default": true
                },
                "color": {
                    "type": "color",
                    "default": "currentColor"
                }
            },
            "label": {
                "color": {
                    "type": "color",
                    "default": "currentColor"
                },
                "format": {
                    "type": "format",
                    "default": ".3s"
                },
                "direction": {
                    "type": "choice",
                    "default": "horizontal",
                    "values": [
                        "horizontal",
                        "vertical"
                    ]
                },
                "padding": {
                    "type": "number",
                    "default": 1,
                    "min": 0,
                    "max": 100,
                    "step": 0.5
                },
                "font": {
                    "family": {
                        "type": "font"
                    },
                    "size": {
                        "type": "quantity",
                        "default": "1em",
                        "units": [
                            {
                                "name": "em",
                                "max": 10,
                                "step": 0.01,
                                "default": 1
                            },
                            {
                                "name": "px",
                                "max": 256,
                                "step": 1,
                                "default": 16
                            }
                        ]
                    }
                }
            },
            "caption": {
                "color": {
                    "type": "color",
                    "default": "currentColor"
                },
                "text": {
                    "type": "text",
                    "default": ""
                },
                "show": {
                    "type": "boolean",
                    "default": true
                },
                "padding": {
                    "type": "number",
                    "default": 1,
                    "min": 0,
                    "max": 100,
                    "step": 0.5
                },
                "font": {
                    "family": {
                        "type": "font"
                    },
                    "size": {
                        "type": "quantity",
                        "default": "1em",
                        "units": [
                            {
                                "name": "em",
                                "max": 10,
                                "step": 0.01,
                                "default": 1
                            },
                            {
                                "name": "px",
                                "max": 256,
                                "step": 1,
                                "default": 16
                            }
                        ]
                    }
                }
            }
        },
        "tip": {
            "enabled": {
                "type": "boolean",
                "default": true
            },
            "format": {
                "type": "format",
                "default": ".3s"
            }
        },
        "yaxis": {
            "enabled": {
                "type": "boolean",
                "default": true
            },
            "tick": {
                "inner": {
                    "type": "number",
                    "name": "Inner Tick Size",
                    "default": 8,
                    "min": 0,
                    "max": 40,
                    "step": 0.1
                },
                "color": {
                    "type": "color",
                    "default": "currentColor"
                },
                "count": {
                    "type": "number",
                    "default": 4,
                    "min": 1,
                    "max": 40
                },
                "boundaryOffset": {
                    "type": "boolean",
                    "default": true
                }
            },
            "baseline": {
                "show": {
                    "type": "boolean",
                    "default": true
                },
                "color": {
                    "type": "color",
                    "default": "currentColor"
                }
            },
            "label": {
                "color": {
                    "type": "color",
                    "default": "currentColor"
                },
                "format": {
                    "type": "format",
                    "default": ".3s"
                },
                "direction": {
                    "type": "choice",
                    "default": "horizontal",
                    "values": [
                        "horizontal",
                        "vertical"
                    ]
                },
                "padding": {
                    "type": "number",
                    "default": 1,
                    "min": 0,
                    "max": 100,
                    "step": 0.5
                },
                "font": {
                    "family": {
                        "type": "font"
                    },
                    "size": {
                        "type": "quantity",
                        "default": "1em",
                        "units": [
                            {
                                "name": "em",
                                "max": 10,
                                "step": 0.01,
                                "default": 1
                            },
                            {
                                "name": "px",
                                "max": 256,
                                "step": 1,
                                "default": 16
                            }
                        ]
                    }
                }
            },
            "caption": {
                "color": {
                    "type": "color",
                    "default": "currentColor"
                },
                "text": {
                    "type": "text",
                    "default": ""
                },
                "show": {
                    "type": "boolean",
                    "default": true
                },
                "padding": {
                    "type": "number",
                    "default": 1,
                    "min": 0,
                    "max": 100,
                    "step": 0.5
                },
                "font": {
                    "family": {
                        "type": "font"
                    },
                    "size": {
                        "type": "quantity",
                        "default": "1em",
                        "units": [
                            {
                                "name": "em",
                                "max": 10,
                                "step": 0.01,
                                "default": 1
                            },
                            {
                                "name": "px",
                                "max": 256,
                                "step": 1,
                                "default": 16
                            }
                        ]
                    }
                }
            },
            "cutoff": {
                "type": "number",
                "default": 0,
                "min": 0,
                "max": 100,
                "step": 0.5
            }
        },
        "mode": {
            "type": "choice",
            "values": [
                "line",
                "area",
                "streamgraph",
                "bump",
                "diff"
            ],
            "default": "line"
        },
        "stack": {
            "type": "boolean"
        },
        "area": {
            "opacity": {
                "type": "number",
                "default": 0.5,
                "min": 0.01,
                "max": 1,
                "step": 0.01
            },
            "offset": {
                "type": "number",
                "default": 0,
                "min": 0,
                "max": 1,
                "step": 0.01
            },
            "percent": {
                "type": "boolean",
                "default": false
            }
        },
        "line": {
            "mode": {
                "type": "choice",
                "values": [
                    "curve",
                    "linear"
                ],
                "default": "linear"
            },
            "strokeWidth": {
                "type": "number",
                "default": 1,
                "min": 0,
                "max": 100,
                "step": 0.5
            },
            "cap": {
                "type": "choice",
                "values": [
                    "butt",
                    "round",
                    "square"
                ],
                "default": "round"
            },
            "join": {
                "type": "choice",
                "values": [
                    "bevel",
                    "miter",
                    "round"
                ],
                "default": "round"
            }
        },
        "diff": {
            "positive": {
                "type": "color",
                "default": "#09f"
            },
            "negative": {
                "type": "color",
                "default": "#f90"
            }
        },
        "dot": {
            "show": {
                "type": "boolean",
                "default": true
            },
            "strokeWidth": {
                "type": "number",
                "default": 1,
                "min": 0,
                "max": 100,
                "step": 0.5
            },
            "fill": {
                "type": "color",
                "default": "auto",
                "presets": [
                    "auto"
                ],
                "i18n": {
                    "en": {
                        "auto": "Auto"
                    },
                    "zh-TW": {
                        "auto": "自動"
                    }
                }
            },
            "size": {
                "type": "number",
                "default": 3,
                "min": 1,
                "max": 100,
                "step": 0.5
            }
        }
    }
};
