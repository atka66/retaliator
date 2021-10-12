extends Node

onready var HitScan = preload("res://objects/HitScan.tscn")
onready var ImpactPar = preload("res://objects/ImpactPar.tscn")
onready var ImpactProjectile = preload("res://objects/ImpactProjectile.tscn")

onready var SoundShotgunShoot = preload("res://sfx/shotgun_1.ogg")
onready var SoundShotgunReload = preload("res://sfx/shotgun_2.ogg")

onready var CrosshairScene = preload("res://objects/Crosshair.tscn")
onready var CustomLabelScene = preload("res://objects/CustomLabel.tscn")
onready var ProjectileScene = preload("res://objects/Projectile.tscn")
