#undef NET_PROTO_STP
#undef NET_PROTO_LACP
#undef NET_PROTO_EAPOL
#define DOWNLOAD_PROTO_HTTP
#define DOWNLOAD_PROTO_NFS
#undef SANBOOT_PROTO_AOE
#undef SANBOOT_PROTO_IB_SRP
#undef SANBOOT_PROTO_FCP
#define SANBOOT_PROTO_HTTP
#undef CRYPTO_80211_WEP
#undef CRYPTO_80211_WPA
#undef CRYPTO_80211_WPA2
#undef EAP_METHOD_MD5
#define IMAGE_SCRIPT
#define IMAGE_UCODE
#undef NVO_CMD
#undef VNIC_IPOIB
// BIOS Only
#ifdef CONSOLE_PCBIOS
#define IMAGE_PXE
#define IMAGE_ELF
#define IMAGE_BZIMAGE
#else
#define IMAGE_EFI
#endif
