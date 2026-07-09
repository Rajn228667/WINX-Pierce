'use client'

import { Suspense, useRef } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { Environment, Float } from '@react-three/drei'
import type { Group } from 'three'

function CctvCamera({ scrollProgress }: { scrollProgress: React.MutableRefObject<number> }) {
  const group = useRef<Group>(null)

  useFrame((state) => {
    if (!group.current) return
    const p = scrollProgress.current
    // Rotate with scroll + gentle idle motion
    group.current.rotation.y = p * Math.PI * 2 + state.clock.elapsedTime * 0.08
    group.current.rotation.x = Math.sin(p * Math.PI) * 0.25
    group.current.position.y = -0.1 + Math.sin(state.clock.elapsedTime * 0.6) * 0.05
  })

  return (
    <Float speed={1.2} rotationIntensity={0.1} floatIntensity={0.2}>
      <group ref={group} dispose={null} scale={1.15}>
        {/* Mount base */}
        <mesh position={[0, 1.05, 0]}>
          <cylinderGeometry args={[0.32, 0.38, 0.12, 32]} />
          <meshStandardMaterial color="#e8e8ec" metalness={0.4} roughness={0.35} />
        </mesh>
        {/* Mount arm */}
        <mesh position={[0, 0.75, 0]}>
          <cylinderGeometry args={[0.07, 0.07, 0.55, 24]} />
          <meshStandardMaterial color="#d8d8dd" metalness={0.5} roughness={0.3} />
        </mesh>
        {/* Joint sphere */}
        <mesh position={[0, 0.45, 0]}>
          <sphereGeometry args={[0.16, 32, 32]} />
          <meshStandardMaterial color="#c9c9cf" metalness={0.6} roughness={0.25} />
        </mesh>
        {/* Camera body - bullet style */}
        <group position={[0, 0.1, 0]} rotation={[0.25, 0, 0]}>
          {/* Main cylinder body */}
          <mesh rotation={[Math.PI / 2, 0, 0]}>
            <cylinderGeometry args={[0.42, 0.42, 1.5, 48]} />
            <meshStandardMaterial color="#f2f2f5" metalness={0.35} roughness={0.3} />
          </mesh>
          {/* Sun shield on top */}
          <mesh position={[0, 0.46, -0.1]} rotation={[Math.PI / 2, 0, 0]}>
            <cylinderGeometry args={[0.46, 0.46, 1.7, 48, 1, false, 0, Math.PI]} />
            <meshStandardMaterial color="#e4e4e9" metalness={0.4} roughness={0.35} />
          </mesh>
          {/* Front lens ring */}
          <mesh position={[0, 0, 0.78]} rotation={[Math.PI / 2, 0, 0]}>
            <cylinderGeometry args={[0.43, 0.4, 0.12, 48]} />
            <meshStandardMaterial color="#1a1a1f" metalness={0.7} roughness={0.2} />
          </mesh>
          {/* Dark glass face */}
          <mesh position={[0, 0, 0.85]} rotation={[Math.PI / 2, 0, 0]}>
            <cylinderGeometry args={[0.38, 0.38, 0.04, 48]} />
            <meshStandardMaterial color="#0a0a10" metalness={0.9} roughness={0.05} />
          </mesh>
          {/* Lens */}
          <mesh position={[0, 0, 0.88]} rotation={[Math.PI / 2, 0, 0]}>
            <cylinderGeometry args={[0.17, 0.17, 0.05, 32]} />
            <meshStandardMaterial color="#101018" metalness={0.9} roughness={0.02} />
          </mesh>
          {/* Lens inner glint */}
          <mesh position={[0.04, 0.04, 0.91]}>
            <sphereGeometry args={[0.035, 16, 16]} />
            <meshStandardMaterial color="#3a4a6a" emissive="#22304a" emissiveIntensity={0.8} metalness={1} roughness={0} />
          </mesh>
          {/* Recording LED */}
          <mesh position={[0.28, 0.2, 0.82]}>
            <sphereGeometry args={[0.028, 16, 16]} />
            <meshStandardMaterial color="#ff2a2a" emissive="#ff1a1a" emissiveIntensity={3} />
          </mesh>
          {/* Rear cap */}
          <mesh position={[0, 0, -0.78]} rotation={[Math.PI / 2, 0, 0]}>
            <cylinderGeometry args={[0.36, 0.42, 0.14, 48]} />
            <meshStandardMaterial color="#dcdce1" metalness={0.4} roughness={0.35} />
          </mesh>
        </group>
      </group>
    </Float>
  )
}

export default function Camera3D({ scrollProgress }: { scrollProgress: React.MutableRefObject<number> }) {
  return (
    <Canvas
      camera={{ position: [0, 0.2, 4.2], fov: 40 }}
      dpr={[1, 2]}
      gl={{ antialias: true, alpha: true }}
      aria-label="3D model of a security camera"
      role="img"
    >
      <ambientLight intensity={0.5} />
      <directionalLight position={[4, 6, 4]} intensity={1.4} />
      <directionalLight position={[-4, 2, -3]} intensity={0.5} color="#ff5544" />
      <pointLight position={[0, -2, 3]} intensity={0.4} color="#ffffff" />
      <Suspense fallback={null}>
        <CctvCamera scrollProgress={scrollProgress} />
        <Environment preset="city" />
      </Suspense>
    </Canvas>
  )
}
