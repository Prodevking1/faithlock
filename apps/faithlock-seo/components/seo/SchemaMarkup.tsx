interface SchemaMarkupProps {
  data: Record<string, unknown> | Record<string, unknown>[]
}

export default function SchemaMarkup({ data }: SchemaMarkupProps) {
  const schemas = Array.isArray(data) ? data : [data]

  return (
    <>
      {schemas.map((schema, index) => (
        <script
          key={index}
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
        />
      ))}
    </>
  )
}
